# Linux & Network Security Lab

A hands-on laboratory dedicated to understanding, reproducing, and analyzing computer networking concepts through controlled experiments using Linux and network analysis tools.

The project focuses on translating networking theory into practical, observable evidence. Each experiment explores specific network behaviors, captures real traffic, analyzes protocol interactions, and documents the findings.

## Objectives

- Reproduce fundamental computer networking concepts through practical experiments.
- Understand how network protocols interact across different layers.
- Observe packet encapsulation and decapsulation in real communication scenarios.
- Analyze ARP resolution, IP and MAC addressing, TCP and UDP communication, segmentation, multiplexing, and application protocols.
- Use packet captures to investigate network behavior at different communication endpoints.
- Develop repeatable experiments supported by technical evidence and documented analysis.

## Laboratory Environment

The initial laboratory consists of two virtual machines running in Oracle VirtualBox:

| Machine | Role | Operating System |
|---|---|---|
| Kali Linux | Analysis and traffic generation | Kali Linux |
| Metasploitable | Target endpoint and network services | Metasploitable |

Both machines are connected through a bridged network adapter and have verified network connectivity.

### Tools and Technologies

Tools will be selected according to the requirements of each experiment. Potential technologies include:

- Wireshark
- tcpdump
- Bash
- Python
- Scapy
- Netcat
- Linux networking utilities

The laboratory is not restricted to a predefined set of tools. Additional technologies may be introduced whenever they provide a better way to reproduce or observe a networking concept.

## Methodology

Every experiment follows the same engineering methodology:

**Theory → Experiment → Evidence → Analysis → Documentation**

1. **Theory:** Identify the networking concept, its purpose, and the expected behavior according to the theoretical material.
2. **Experiment:** Design and execute a controlled scenario to reproduce the concept.
3. **Evidence:** Collect packet captures, command outputs, and other relevant artifacts.
4. **Analysis:** Examine the collected evidence and compare observed behavior with theoretical expectations.
5. **Documentation:** Record the procedure, findings, limitations, and conclusions.

A clear distinction will be maintained between theoretical expectations and behaviors directly demonstrated by the experiments.

## Experiments Roadmap

The initial roadmap is organized into the following experiments:

| # | Experiment | Main Topics |
|---|---|---|
| 01 | ARP and Address Resolution | ARP requests, replies, and ARP cache |
| 02 | Encapsulation and Decapsulation | Protocol layers, headers, and PDUs |
| 03 | IP vs. MAC Addressing | Logical addressing, physical addressing, and communication paths |
| 04 | Segmentation and Multiplexing | TCP segmentation and concurrent communication flows |
| 05 | TCP vs. UDP | Connection-oriented and connectionless communication |
| 06 | Ports and Application Protocols | Source ports, destination ports, and application services |

The roadmap may evolve as experiments reveal opportunities for deeper investigation or additional practical demonstrations.

## Project Structure

```text
linux-network-security-lab/
│
├── README.md
│
├── docs/
│   ├── architecture/
│   ├── theory/
│   └── experiments/
│
├── experiments/
│   ├── 01-arp/
│   ├── 02-encapsulation-decapsulation/
│   ├── 03-ip-vs-mac/
│   ├── 04-segmentation-multiplexing/
│   ├── 05-tcp-vs-udp/
│   └── 06-ports-and-applications/
│
├── captures/
│   ├── 01-arp/
│   ├── 02-encapsulation-decapsulation/
│   ├── 03-ip-vs-mac/
│   ├── 04-segmentation-multiplexing/
│   ├── 05-tcp-vs-udp/
│   └── 06-ports-and-applications/
│
├── scripts/
│
└── reports/
```

## Evidence and Reproducibility

Experiments should produce reproducible technical evidence whenever possible.

Depending on the scenario, evidence may include:

- PCAP or PCAPNG packet captures.
- Wireshark protocol analysis.
- Terminal outputs.
- Scripts and execution commands.
- Network configuration details.
- Technical reports and observations.

Captures and supporting artifacts will be organized by experiment to facilitate review, comparison, and future reproduction.

## Scope and Principles

This project is primarily focused on computer networking.

Linux is the experimental environment, while network protocols and communication behaviors are the main subjects of investigation.

The laboratory may include complementary concepts and tools beyond the original course material when they help demonstrate networking principles more effectively.

All experiments will be conducted within the controlled laboratory environment.

## Author

**Fernando Magalhães**  
CEO, FM ByteShift Software

- [FM ByteShift Software](https://fmbyteshiftsoftware.com/)
- [Cybersecurity Pain Intelligence](https://cybersecuritypainintelligence.com/)
