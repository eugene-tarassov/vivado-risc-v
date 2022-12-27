// SPDX-License-Identifier: GPL-2.0-or-later

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/interrupt.h>
#include <linux/etherdevice.h>
#include <linux/ethtool.h>
#include <linux/of_device.h>
#include <linux/of_mdio.h>
#include <linux/of_net.h>
#include <linux/phy.h>

/*
* AXI Ethernet driver.
*
* AXI Ethernet is open source Verilog implementation of high speed ethernet adapter.
* It is mainly used in FPGA designs.
*/

#ifdef CONFIG_DEBUG_INFO
#pragma GCC optimize("O0")
#endif

#define AXI_ETH_MIN_MTU (ETH_ZLEN + ETH_HLEN)
#define AXI_ETH_MAX_MTU 9000

#define AXI_ETH_RING_MASK 0xf
#define AXI_ETH_RING_SIZE (AXI_ETH_RING_MASK + 1)

struct eth_regs {
    volatile uint32_t mac_status;
    volatile uint32_t nic_status;
    volatile uint32_t int_enable;
    volatile uint32_t int_status;
    volatile uint32_t rx_inp;
    volatile uint32_t rx_out;
    volatile uint32_t tx_inp;
    volatile uint32_t tx_out;
    volatile uint32_t nic_control;
    volatile uint32_t mdio_tx;
    volatile uint32_t mdio_rx;
    volatile uint32_t capability;
};

struct eth_pkt_regs {
    volatile uint32_t addr;
    volatile uint32_t size;
    volatile uint32_t done;
    volatile uint32_t status;
};

#define MAC_STATUS_LINK_OK      (1 << 0)
#define MAC_STATUS_LINK_SYNC    (1 << 1)
#define MAC_STATUS_RUDI_C       (1 << 2)
#define MAC_STATUS_RUDI_I       (1 << 3)
#define MAC_STATUS_RUDI_ERR     (1 << 4)
#define MAC_STATUS_RXDISPERR    (1 << 5)
#define MAC_STATUS_RXNOTINTABLE (1 << 6)
#define MAC_STATUS_PHY_LINK_OK  (1 << 7)
#define MAC_STATUS_SPEED_100    (1 << 10)
#define MAC_STATUS_SPEED_1000   (1 << 11)
#define MAC_STATUS_DUPLEX       (1 << 12)
#define MAC_STATUS_REMOTE_FAULT (1 << 13)
#define MAC_STATUS_PAUSE_SYM    (1 << 14)
#define MAC_STATUS_PAUSE_ASYM   (1 << 15)

#define NIC_STATUS_RX_BUSY      (1 << 0)
#define NIC_STATUS_TX_BUSY      (1 << 1)
#define NIC_STATUS_AXI_WR_CYC   (1 << 2)
#define NIC_STATUS_AXI_WR_ERR   (1 << 3)
#define NIC_STATUS_AXI_RD_CYC   (1 << 4)
#define NIC_STATUS_AXI_RD_ERR   (1 << 5)

#define INT_STATUS_RX           (1 << 16)
#define INT_STATUS_TX           (1 << 17)
#define INT_STATUS_MDIO         (1 << 18)
#define INT_STATUS_PHY          (1 << 19)

#define NIC_CONTROL_EN_RX       (1 << 0)
#define NIC_CONTROL_EN_TX       (1 << 1)
#define NIC_CONTROL_MDIO_RESET  (1 << 2)

#define MDIO_RESET_DELAY        10
#define MDIO_POLL_DELAY         4

#define NIC_CAPABILITY_BURST    0x000f
#define NIC_CAPABILITY_RING     0x00f0
#define NIC_CAPABILITY_MDIO     0x0100
#define NIC_CAPABILITY_ADDR     0xfc00

#define PKT_STATUS_BAD_FRAME    (1 << 0)
#define PKT_STATUS_BUS_ERROR    (1 << 1)

struct axi_eth_ring_item {
    struct sk_buff * skb;
    dma_addr_t dma_addr;
    unsigned dma_size;
};

struct axi_eth_stats {
    u64 packets;
    u64 bytes;
    struct u64_stats_sync syncp;
};

struct axi_eth_priv {
    struct eth_regs __iomem * regs;
    struct eth_pkt_regs __iomem * rx_pkt_regs;
    struct eth_pkt_regs __iomem * tx_pkt_regs;
    struct platform_device * pdev;
    struct net_device * net_dev;
    struct phy_device * phy_dev;
    struct mii_bus * mdio_bus;
    unsigned dma_addr_bits;
    spinlock_t lock;
    int irq;

    uint32_t int_enable;
    struct axi_eth_ring_item rx_ring[AXI_ETH_RING_SIZE];
    struct axi_eth_ring_item tx_ring[AXI_ETH_RING_SIZE];
    uint32_t rx_inp;
    uint32_t rx_out;
    uint32_t tx_inp;
    uint32_t tx_out;

    struct axi_eth_stats rx_stats;
    struct axi_eth_stats tx_stats;
};

#define tx_ring_free(p) ((p->tx_out - p->tx_inp - 1) & AXI_ETH_RING_MASK)

#define DRIVER_NAME "riscv-axi-eth"
#define MDIO_BUS_NAME "axi-eth-mdio"

static u32 axi_eth_debug = 0;

static const struct of_device_id axi_eth_of_match_table[] = {
    { .compatible = "riscv,axi-ethernet-1.0" },
    {},
};
MODULE_DEVICE_TABLE(of, axi_eth_of_match_table);

static int axi_eth_mdio_write(struct mii_bus * bus, int addr, int regnum, u16 value) {
    struct axi_eth_priv * priv = bus->priv;
    uint32_t tx = (0x5 << 28) | ((addr & 0x1f) << 23) | ((regnum & 0x1f) << 18) | value;
    uint32_t rx = 0;
    unsigned timeout = 0;
    unsigned tx_chk = tx & 0xfffcffff;
    unsigned rx_chk = 0;

    spin_lock_irq(&priv->lock);
    priv->regs->mdio_tx = tx;
    while ((priv->regs->int_status & INT_STATUS_MDIO) == 0) {
        if (timeout >= 10) {
            spin_unlock_irq(&priv->lock);
            return -ETIME;
        }
        udelay(MDIO_POLL_DELAY);
        timeout++;
    }
    rx = priv->regs->mdio_rx;
    spin_unlock_irq(&priv->lock);

    rx_chk = rx & 0xfffcffff;
    if (tx_chk != rx_chk) return -EIO;
    return 0;
}

static int axi_eth_mdio_read(struct mii_bus * bus, int addr, int regnum) {
    struct axi_eth_priv * priv = bus->priv;
    uint32_t tx = (0x6 << 28) | ((addr & 0x1f) << 23) | ((regnum & 0x1f) << 18);
    uint32_t rx = 0;
    unsigned timeout = 0;
    unsigned tx_chk = tx & 0xfffc0000;
    unsigned rx_chk = 0;

    spin_lock_irq(&priv->lock);
    priv->regs->mdio_tx = tx;
    while ((priv->regs->int_status & INT_STATUS_MDIO) == 0) {
        if (timeout >= 10) {
            spin_unlock_irq(&priv->lock);
            return -ETIME;
        }
        udelay(MDIO_POLL_DELAY);
        timeout++;
    }
    rx = priv->regs->mdio_rx;
    spin_unlock_irq(&priv->lock);

    rx_chk = rx & 0xfffc0000;
    if (tx_chk != rx_chk) return -EIO;
    return rx & 0xffff;
}

static int axi_eth_mdio_reset(struct mii_bus * bus) {
    struct axi_eth_priv * priv = bus->priv;
    unsigned timeout = 0;

    priv->regs->nic_control |= NIC_CONTROL_MDIO_RESET;
    for (timeout = 0; timeout < 1000; timeout++) {
        int rd = axi_eth_mdio_read(bus, 0, 2);
        if (rd == 0xffff) break;
        udelay(MDIO_RESET_DELAY);
    }
    udelay(MDIO_RESET_DELAY);

    priv->regs->nic_control &= ~NIC_CONTROL_MDIO_RESET;
    for (timeout = 0; timeout < 1000; timeout++) {
        int rd = axi_eth_mdio_read(bus, 0, 2);
        if (rd > 0 && rd < 0xffff) break;
        udelay(MDIO_RESET_DELAY);
    }
    udelay(MDIO_RESET_DELAY);

    return 0;
}

static void axi_eth_mdio_poll(struct net_device * net_dev) {
}

static int axi_eth_mdio_register(struct axi_eth_priv * priv) {
    struct mii_bus * mdio_bus = mdiobus_alloc();
    struct device_node * np = priv->pdev->dev.of_node;
    int err = 0;

    if (!mdio_bus) return -ENOMEM;

    mdio_bus->priv = priv;
    mdio_bus->parent = &priv->pdev->dev;
    mdio_bus->name = MDIO_BUS_NAME;
    snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%d", mdio_bus->name, priv->pdev->id);

    mdio_bus->read = axi_eth_mdio_read;
    mdio_bus->write = axi_eth_mdio_write;
    mdio_bus->reset = axi_eth_mdio_reset;

    if (np != NULL) {
        struct device_node * child;
        unsigned phy_cnt = 0;
        for_each_available_child_of_node(np, child) {
            if (of_mdiobus_child_is_phy(child)) phy_cnt++;
        }
        if (phy_cnt == 0) np = NULL;
    }

    err = of_mdiobus_register(mdio_bus, np);
    if (err) {
        mdiobus_free(mdio_bus);
        return err;
    }

    priv->mdio_bus = mdio_bus;
    return 0;
}

static void axi_eth_rx_done(struct net_device * net_dev, struct axi_eth_ring_item * i) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    struct sk_buff * skb = i->skb;
    uint32_t status = priv->rx_pkt_regs[priv->rx_out].status;
    dma_unmap_single(&priv->pdev->dev, i->dma_addr, i->dma_size, DMA_FROM_DEVICE);
    if (status & PKT_STATUS_BAD_FRAME) {
        dev_kfree_skb_any(skb);
        net_dev->stats.rx_dropped++;
    }
    else if (status & PKT_STATUS_BUS_ERROR) {
        dev_kfree_skb_any(skb);
        net_dev->stats.rx_errors++;
    }
    else {
        skb->dev = net_dev;
        skb_put(skb, priv->rx_pkt_regs[priv->rx_out].done);
        skb->protocol = eth_type_trans(skb, net_dev);
        skb->ip_summed = CHECKSUM_NONE;
        u64_stats_update_begin(&priv->rx_stats.syncp);
        priv->rx_stats.packets++;
        priv->rx_stats.bytes += skb->len;
        u64_stats_update_end(&priv->rx_stats.syncp);
        netif_rx(skb);
    }
    i->skb = NULL;
}

static void axi_eth_tx_done(struct net_device * net_dev, struct axi_eth_ring_item * i) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    struct sk_buff * skb = i->skb;
    u64_stats_update_begin(&priv->tx_stats.syncp);
    priv->tx_stats.packets++;
    priv->tx_stats.bytes += skb->len;
    u64_stats_update_end(&priv->tx_stats.syncp);
    dev_consume_skb_any(skb);
    dma_unmap_single(&priv->pdev->dev, i->dma_addr, i->dma_size, DMA_TO_DEVICE);
    i->skb = NULL;
}

static netdev_tx_t axi_eth_xmit(struct sk_buff * skb, struct net_device * net_dev) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    const char * err = NULL;
    unsigned pkt_size = 0;
    dma_addr_t dma_addr;

    spin_lock_irq(&priv->lock);

    if (skb->len < ETH_ZLEN && skb_padto(skb, ETH_ZLEN)) {
        err = "Padding error\n";
    }
    else if (skb->len > 0x3fff) {
        err = "Packet too large\n";
    }
    else if (skb->data_len > 0) {
        /* If there are page buffers, the total number of bytes in the page buffer area is 'data_len' */
        err = "Paging error\n";
    }
    else {
        pkt_size = skb->len;
        dma_addr = dma_map_single(&priv->pdev->dev, skb->data, pkt_size, DMA_TO_DEVICE);
        if (dma_mapping_error(&priv->pdev->dev, dma_addr)) {
            err = "DMA mapping error\n";
        }
        else if (dma_addr + pkt_size > ((uint64_t)1 << priv->dma_addr_bits)) {
            dma_unmap_single(&priv->pdev->dev, dma_addr, pkt_size, DMA_TO_DEVICE);
            err = "DMA mapping error: address overflow\n";
        }
    }

    if (err) {
        net_dev->stats.tx_dropped++;
        netdev_err(net_dev, err);
        dev_kfree_skb_any(skb);
    }
    else {
        uint32_t tx_next = (priv->tx_inp + 1) & AXI_ETH_RING_MASK;
        struct axi_eth_ring_item * i = priv->tx_ring + priv->tx_inp;
        if (tx_next == priv->tx_out) {
            struct axi_eth_ring_item * i = priv->tx_ring + priv->tx_out;
            while (priv->tx_out == priv->regs->tx_out) {}
            if (i->skb) axi_eth_tx_done(net_dev, i);
            priv->tx_out = (priv->tx_out + 1) & AXI_ETH_RING_MASK;
        }

        skb_tx_timestamp(skb);

        i->skb = skb;
        i->dma_size = pkt_size;
        i->dma_addr = dma_addr;
        priv->tx_pkt_regs[priv->tx_inp].addr = i->dma_addr; wmb();
        priv->tx_pkt_regs[priv->tx_inp].size = i->dma_size | ((i->dma_addr >> 32) << 16); wmb();
        priv->regs->tx_inp = priv->tx_inp = tx_next;

        if (tx_ring_free(priv) == 0) netif_stop_queue(net_dev);
    }

    spin_unlock_irq(&priv->lock);

    return NETDEV_TX_OK;
}

static void axi_eth_get_stats64(struct net_device * net_dev, struct rtnl_link_stats64 * stats) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    unsigned int start;

    netdev_stats_to_stats64(stats, &net_dev->stats);

    do {
        start = u64_stats_fetch_begin_irq(&priv->rx_stats.syncp);
        stats->rx_packets = priv->rx_stats.packets;
        stats->rx_bytes = priv->rx_stats.bytes;
    }
    while (u64_stats_fetch_retry_irq(&priv->rx_stats.syncp, start));

    do {
        start = u64_stats_fetch_begin_irq(&priv->tx_stats.syncp);
        stats->tx_packets = priv->tx_stats.packets;
        stats->tx_bytes = priv->tx_stats.bytes;
    }
    while (u64_stats_fetch_retry_irq(&priv->tx_stats.syncp, start));
}

static void axi_eth_add_rx_buffers(struct net_device * net_dev) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    unsigned pkt_size = net_dev->mtu + ETH_HLEN;
    if (pkt_size > 0x3fff) pkt_size = 0x3fff;
    for (;;) {
        const char * err = NULL;
        struct axi_eth_ring_item * i;
        struct sk_buff * skb;
        dma_addr_t dma_addr;
        uint32_t rx_next = (priv->rx_inp + 1) & AXI_ETH_RING_MASK;

        if (rx_next == priv->rx_out) break;
        i = priv->rx_ring + priv->rx_inp;
        skb = netdev_alloc_skb_ip_align(net_dev, pkt_size);
        if (!skb) {
            netdev_err(net_dev, "Cannot allocate DMA buffer\n");
            net_dev->stats.rx_errors++;
            return;
        }
        dma_addr = dma_map_single(&priv->pdev->dev, skb->data, pkt_size, DMA_FROM_DEVICE);
        if (dma_mapping_error(&priv->pdev->dev, dma_addr)) {
            err = "DMA mapping error\n";
        }
        else if (dma_addr + pkt_size > ((uint64_t)1 << priv->dma_addr_bits)) {
            dma_unmap_single(&priv->pdev->dev, dma_addr, pkt_size, DMA_FROM_DEVICE);
            err = "DMA mapping error: address overflow\n";
        }
        if (err) {
            netdev_err(net_dev, err);
            net_dev->stats.rx_errors++;
            dev_kfree_skb_any(skb);
            return;
        }
        i->skb = skb;
        i->dma_size = pkt_size;
        i->dma_addr = dma_addr;
        priv->rx_pkt_regs[priv->rx_inp].addr = i->dma_addr; wmb();
        priv->rx_pkt_regs[priv->rx_inp].size = i->dma_size | ((i->dma_addr >> 32) << 16); wmb();
        priv->regs->rx_inp = priv->rx_inp = rx_next;
    }
}

static int axi_eth_change_mtu(struct net_device * net_dev, int new_mtu) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);

    if (net_dev->mtu < new_mtu) {
        spin_lock_irq(&priv->lock);

        /* Disable RX */
        priv->regs->nic_control &= ~NIC_CONTROL_EN_RX;
        /* Wait active RX to finish */
        while (priv->regs->nic_status & 1) {}
        /* Dispose RX buffers - too small for new MTU */
        while (priv->rx_inp != priv->rx_out) {
            struct axi_eth_ring_item * i = priv->rx_ring + priv->rx_out;
            struct sk_buff * skb = i->skb;
            if (skb) {
                dev_kfree_skb_any(skb);
                dma_unmap_single(&priv->pdev->dev, i->dma_addr, i->dma_size, DMA_FROM_DEVICE);
                i->skb = NULL;
            }
            priv->rx_out = (priv->rx_out + 1) & AXI_ETH_RING_MASK;
        }
        priv->regs->rx_out = priv->rx_out;
        axi_eth_add_rx_buffers(net_dev);
        /* Enable RX */
        priv->regs->nic_control |= NIC_CONTROL_EN_RX;

        spin_unlock_irq(&priv->lock);
    }

    net_dev->mtu = new_mtu;
    return 0;
}

static irqreturn_t axi_eth_isr(int irq, void * dev_id) {
    struct net_device * net_dev = dev_id;
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    unsigned long flags;

    spin_lock_irqsave(&priv->lock, flags);

    for (;;) {
        int cont = 0;
        axi_eth_add_rx_buffers(net_dev);
        priv->regs->int_status = 0;
        if (priv->rx_out != priv->regs->rx_out) {
            struct axi_eth_ring_item * i = priv->rx_ring + priv->rx_out;
            wmb();
            if (i->skb) axi_eth_rx_done(net_dev, i);
            priv->rx_out = (priv->rx_out + 1) & AXI_ETH_RING_MASK;
            cont = 1;
        }
        if (priv->tx_out != priv->regs->tx_out) {
            struct axi_eth_ring_item * i = priv->tx_ring + priv->tx_out;
            if (i->skb) axi_eth_tx_done(net_dev, i);
            priv->tx_out = (priv->tx_out + 1) & AXI_ETH_RING_MASK;
            cont = 1;
        }
        if (!cont) break;
    }

    if (netif_queue_stopped(net_dev) &&
        tx_ring_free(priv) >= AXI_ETH_RING_SIZE / 2)
        netif_wake_queue(net_dev);

    spin_unlock_irqrestore(&priv->lock, flags);

    return IRQ_HANDLED;
}

static int axi_eth_ioctl(struct net_device * net_dev, struct ifreq * ifr, int cmd) {
    struct mii_ioctl_data * data = if_mii(ifr);
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    int err = 0;

    if (priv->mdio_bus != NULL) {
        switch (cmd) {
        case SIOCGMIIPHY:
        case SIOCGMIIREG:
            if (cmd == SIOCGMIIPHY) {
                if (priv->phy_dev == NULL) return -EAGAIN;
                data->phy_id = priv->phy_dev->mdio.addr;
            }
            err = axi_eth_mdio_read(priv->mdio_bus, data->phy_id, data->reg_num);
            if (err < 0) return err;
            data->val_out = (__u16)err;
            return 0;

        case SIOCSMIIREG:
            return axi_eth_mdio_write(priv->mdio_bus, data->phy_id, data->reg_num, data->val_in);
        }
    }

    return -EOPNOTSUPP;
}

static void axi_eth_get_drvinfo(struct net_device * dev, struct ethtool_drvinfo * info) {
    strlcpy(info->driver, DRIVER_NAME, sizeof(info->driver));
}

static u32 axi_eth_get_msglevel(struct net_device * dev) {
    return axi_eth_debug;
}

static void axi_eth_set_msglevel(struct net_device * dev, u32 v) {
    axi_eth_debug = v;
}

static const struct ethtool_ops axi_eth_ethtool_ops = {
    .get_drvinfo    = axi_eth_get_drvinfo,
    .get_msglevel   = axi_eth_get_msglevel,
    .set_msglevel   = axi_eth_set_msglevel,
    .get_link       = ethtool_op_get_link,
    .get_link_ksettings = phy_ethtool_get_link_ksettings,
    .set_link_ksettings = phy_ethtool_set_link_ksettings,
    .get_ts_info    = ethtool_op_get_ts_info,
};

static int axi_eth_dev_init(struct net_device * net_dev) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    int err = 0;

    spin_lock_irq(&priv->lock);

    priv->regs->int_enable = priv->int_enable = 0;
    err = request_irq(priv->irq, axi_eth_isr, IRQF_TRIGGER_HIGH, DRIVER_NAME, net_dev);
    if (err) return err;

    priv->rx_inp = priv->regs->rx_inp;
    priv->rx_out = priv->regs->rx_out;
    priv->tx_inp = priv->regs->tx_inp;
    priv->tx_out = priv->regs->tx_out;

    u64_stats_init(&priv->rx_stats.syncp);
    u64_stats_init(&priv->tx_stats.syncp);

    spin_unlock_irq(&priv->lock);

    return 0;
}

static int axi_eth_dev_close(struct net_device * net_dev) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);

    spin_lock_irq(&priv->lock);

    priv->regs->int_enable = 0;

    /* Disable RX, TX */
    priv->regs->nic_control = 0;
    /* Wait active RX, TX to finish */
    while (priv->regs->nic_status & 3) {}

    while (priv->rx_inp != priv->rx_out) {
        struct axi_eth_ring_item * i = priv->rx_ring + priv->rx_out;
        struct sk_buff * skb = i->skb;
        if (skb) {
            dev_kfree_skb_any(skb);
            dma_unmap_single(&priv->pdev->dev, i->dma_addr, i->dma_size, DMA_FROM_DEVICE);
            i->skb = NULL;
        }
        priv->rx_out = (priv->rx_out + 1) & AXI_ETH_RING_MASK;
    }
    priv->regs->rx_out = priv->rx_out;

    while (priv->tx_inp != priv->tx_out) {
        struct axi_eth_ring_item * i = priv->tx_ring + priv->tx_out;
        while (priv->tx_out == priv->regs->tx_out) {}
        if (i->skb) axi_eth_tx_done(net_dev, i);
        priv->tx_out = (priv->tx_out + 1) & AXI_ETH_RING_MASK;
    }
    priv->regs->tx_out = priv->tx_out;

    spin_unlock_irq(&priv->lock);

    if (priv->phy_dev != NULL) {
        phy_disconnect(priv->phy_dev);
        priv->phy_dev = NULL;
    }

    return 0;
}

static int axi_eth_dev_open(struct net_device * net_dev) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    int err = 0;

    if (priv->mdio_bus != NULL) {
        phy_interface_t phy_intf = PHY_INTERFACE_MODE_RGMII;

        priv->phy_dev = phy_find_first(priv->mdio_bus);
        if (priv->phy_dev == NULL) return -ENODEV;

        err = of_get_phy_mode(priv->pdev->dev.of_node, &phy_intf);
        if (err && err != -ENODEV) return err;

        err = phy_connect_direct(net_dev, priv->phy_dev, axi_eth_mdio_poll, phy_intf);
        if (err) {
            printk(KERN_ERR "AXI-ETH: Can't attach PHY\n");
            return err;
        }

        phy_start(priv->phy_dev);
    }

    spin_lock_irq(&priv->lock);

    axi_eth_add_rx_buffers(net_dev);
    priv->regs->int_enable = priv->int_enable = INT_STATUS_RX | INT_STATUS_TX;

    /* Enable RX, TX, clear MDIO reset */
    priv->regs->nic_control = NIC_CONTROL_EN_RX | NIC_CONTROL_EN_TX;

    spin_unlock_irq(&priv->lock);

    return 0;
}

static void axi_eth_dev_free(struct net_device * net_dev) {
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    free_irq(priv->irq, priv);
}

static const struct net_device_ops axi_eth_ops = {
    .ndo_init        = axi_eth_dev_init,
    .ndo_open        = axi_eth_dev_open,
    .ndo_stop        = axi_eth_dev_close,
    .ndo_eth_ioctl   = axi_eth_ioctl,
    .ndo_start_xmit  = axi_eth_xmit,
    .ndo_get_stats64 = axi_eth_get_stats64,
    .ndo_set_mac_address = eth_mac_addr,
    .ndo_change_mtu = axi_eth_change_mtu,
#ifdef CONFIG_NET_POLL_CONTROLLER
    .ndo_poll_controller = axi_eth_poll_controller,
#endif
};

/* Setup and register the device. */
static int axi_eth_probe(struct platform_device * pdev) {
    struct net_device * net_dev = NULL;
    struct axi_eth_priv * priv = NULL;
    struct resource * iomem;
    void __iomem * ioaddr;
    uint32_t capability;
    int err = -ENOMEM;
    const u8 * maddr;
    int len;
    int irq;

    iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    ioaddr = devm_ioremap_resource(&pdev->dev, iomem);
    if (IS_ERR(ioaddr)) return PTR_ERR(ioaddr);

    irq = platform_get_irq(pdev, 0);
    if (irq <= 0) return -ENXIO;

    net_dev = alloc_etherdev(sizeof(struct axi_eth_priv));
    if (!net_dev) goto out;

    net_dev->min_mtu = AXI_ETH_MIN_MTU;
    net_dev->max_mtu = AXI_ETH_MAX_MTU;
    net_dev->ethtool_ops = &axi_eth_ethtool_ops;
    net_dev->netdev_ops = &axi_eth_ops;
    net_dev->needs_free_netdev = true;
    net_dev->priv_destructor = axi_eth_dev_free;
    net_dev->dev.parent = &pdev->dev;

    priv = netdev_priv(net_dev);
    spin_lock_init(&priv->lock);
    priv->regs = (struct eth_regs __iomem *)ioaddr;
    priv->rx_pkt_regs = (struct eth_pkt_regs __iomem *)((char *)ioaddr + 0x800);
    priv->tx_pkt_regs = (struct eth_pkt_regs __iomem *)((char *)ioaddr + 0xc00);
    priv->pdev = pdev;
    priv->net_dev = net_dev;
    priv->irq = irq;

    maddr = of_get_property(pdev->dev.of_node, "local-mac-address", &len);
    if (maddr && len == ETH_ALEN) {
        net_dev->addr_len = ETH_ALEN;
        dev_addr_set(net_dev, maddr);
    }
    else {
        printk(KERN_ERR "AXI-ETH: Can't get MAC address\n");
        err = -ENODEV;
        goto out;
    }

    priv->dma_addr_bits = 32;
    capability = priv->regs->capability;
    if (capability & NIC_CAPABILITY_ADDR) {
        priv->dma_addr_bits = (capability & NIC_CAPABILITY_ADDR) >> __builtin_ctz(NIC_CAPABILITY_ADDR);
        err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(priv->dma_addr_bits));
        if (err) {
            printk(KERN_ERR "AXI-ETH: Can't set DMA mask\n");
            goto out;
        }
    }

    if (capability & NIC_CAPABILITY_MDIO) {
        err = axi_eth_mdio_register(priv);
        if (err) {
            printk(KERN_ERR "AXI-ETH: Can't register MDIO bus\n");
            goto out;
        }
    }

    err = register_netdev(net_dev);
    if (err) {
        printk(KERN_ERR "AXI-ETH: Can't register net device\n");
        goto out;
    }

    return 0;

out:
    if (priv->mdio_bus != NULL) {
        mdiobus_unregister(priv->mdio_bus);
        mdiobus_free(priv->mdio_bus);
    }
    if (net_dev) free_netdev(net_dev);
    return err;
}

static int axi_eth_remove(struct platform_device * pdev) {
    struct net_device * net_dev = platform_get_drvdata(pdev);
    struct axi_eth_priv * priv = netdev_priv(net_dev);
    unregister_netdev(net_dev);
    if (priv->mdio_bus != NULL) {
        mdiobus_unregister(priv->mdio_bus);
        mdiobus_free(priv->mdio_bus);
    }
    free_netdev(net_dev);
    return 0;
}

static struct platform_driver axi_eth_driver = {
    .driver = {
        .name = DRIVER_NAME,
        .of_match_table = axi_eth_of_match_table,
    },
    .probe = axi_eth_probe,
    .remove = axi_eth_remove,
};

module_platform_driver(axi_eth_driver);

MODULE_DESCRIPTION("AXI Ethernet driver");
MODULE_AUTHOR("Eugene Tarassov");
MODULE_LICENSE("GPL v2");
