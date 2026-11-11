# ARP Resolution Experiment

## 1. Overview

This experiment demonstrates how the Address Resolution Protocol (ARP) resolves an IPv4 address into a MAC address within a local network.

The experiment uses Bash, `ip`, `ping`, and `tcpdump` to inspect the ARP neighbor cache, remove an existing entry, generate network traffic, and capture the resulting ARP exchange.

The objective is to observe the ARP resolution process in practice and understand how a device discovers the MAC address associated with an IPv4 destination.

## 2. Objectives

- Inspect an existing ARP neighbor cache entry.
- Remove a specific neighbor cache entry.
- Capture ARP packets using `tcpdump`.
- Generate network traffic to trigger a new ARP resolution.
- Identify and analyze ARP Request and ARP Reply packets.
- Save packet-level evidence in PCAP format for further analysis.

## 3. Requirements

The experiment was developed and tested in Kali Linux.

Required tools:

| Tool | Purpose |
|---|---|
| `ip` | Network interface discovery and ARP neighbor cache management |
| `ping` | Generate network traffic |
| `tcpdump` | Capture and analyze ARP packets |
| `sudo` | Execute privileged network operations |
| `awk` | Extract the network interface from routing information |

Administrative privileges are required for ARP cache manipulation and packet capture.

## 4. Experiment Workflow

The script (`arp-experiment.sh`) follows these steps:

1. **Argument validation:** validates the destination IPv4 address.
2. **Dependency verification:** checks whether the required tools are available.
3. **Network interface discovery:** uses `ip route get` to identify the interface selected for the destination.
4. **ARP cache inspection:** checks whether an existing neighbor cache entry is available.
5. **ARP cache removal:** removes the existing entry using `ip neigh del`.
6. **Packet capture initialization:** starts `tcpdump` in the background and saves captured ARP packets to a PCAP file.
7. **Traffic generation:** sends four ICMP Echo Requests using `ping`.
8. **Packet capture termination:** stops the background capture process and waits for its termination.
9. **Results presentation:** reads the PCAP file and displays the captured ARP packets.

The packet capture runs concurrently with traffic generation, allowing the experiment to observe the ARP exchange triggered by the network communication.

## 5. Execution

Run the experiment by providing the destination IPv4 address:

```bash
./arp-experiment.sh <destination_ip>
```

Example:

```bash
./arp-experiment.sh 192.168.15.34
```

The script automatically discovers the appropriate network interface.

No manual interface configuration is required.

## 6. Observed Results

During testing, the following network configuration was observed:

| Parameter | Value |
|---|---|
| Source IPv4 address | `192.168.15.33` |
| Destination IPv4 address | `192.168.15.34` |
| Network interface | `eth0` |
| Destination MAC address | `08:00:27:3b:fd:a0` |

The initial ARP cache contained an existing entry in the `STALE` state.

After removing that entry and generating network traffic, the capture recorded two ARP packets:

**ARP Request**

```text
ARP, Request who-has 192.168.15.34 tell 192.168.15.33, length 28
```

The source device broadcasts an ARP request asking which device owns the IPv4 address `192.168.15.34`.

**ARP Reply**

```text
ARP, Reply 192.168.15.34 is-at 08:00:27:3b:fd:a0, length 46
```

The destination device responds with its MAC address, allowing the source device to update its neighbor cache.

The ICMP test also completed successfully:

```text
4 packets transmitted, 4 received, 0% packet loss
```

## 7. Evidence and Packet Analysis

The experiment generates the following evidence file:

```text
arp-resolution.pcap
```

The PCAP file contains the captured ARP packets and can be analyzed independently of the script.

To inspect the captured packets using `tcpdump`:

```bash
tcpdump -nn -r arp-resolution.pcap
```

Alternatively, open the file using Wireshark for graphical packet inspection.

The PCAP file is generated in the current working directory and is overwritten when the experiment runs again.

## 8. Key Technical Concepts

### ARP Neighbor Cache

Operating systems maintain a neighbor cache to associate IPv4 addresses with MAC addresses on local network links.

Removing an existing entry forces the system to resolve the destination address again when communication requires it.

### ARP Request

An ARP Request is used to discover the MAC address associated with a given IPv4 address.

It is normally broadcast across the local network segment.

### ARP Reply

An ARP Reply provides the requested MAC address, allowing the requesting device to establish the corresponding neighbor mapping.

### Packet Capture

`tcpdump` captures network packets at the selected interface and writes them to a PCAP file.

Running the capture in the background allows packet collection to continue while the script generates network traffic.

## 9. Important Notes

- ARP resolution applies to local network links. When communicating with a remote network, the source device generally resolves the MAC address of its next-hop gateway instead of the remote destination.
- The capture filter is `arp`, so the PCAP file may contain other ARP traffic observed on the selected interface, not exclusively packets involving the destination address.
- Successful ICMP communication is not required for ARP packets to be captured. The ARP exchange may still occur even when the destination does not respond to ping.
- Run the experiment only on networks and systems you are authorized to inspect.

## 10. Conclusion

This experiment demonstrates the relationship between the ARP neighbor cache and network communication.

By removing an existing cache entry, generating traffic, and capturing the resulting packets, it becomes possible to observe the ARP Request and ARP Reply exchange that establishes the IPv4-to-MAC address mapping.

The resulting PCAP file provides reproducible, packet-level evidence of the resolution process.