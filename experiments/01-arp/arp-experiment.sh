
#!/usr/bin/env bash

# ------------------------------------------------------------------------
# Script:          arp-experiment.sh
# Description:     ARP Address Resolution Experiment
# Author:          Fernando Magalhaes / cybersecuritypainintelligence.com
# Version:         1.0.0
# ------------------------------------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_VERSION="1.0.0"
readonly CAPTURE_FILE="arp-resolution.pcap"

CAPTURE_PID=""


# ------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------

show_banner() {
    echo "
=============================
+ ARP Resolution Experiment +
=============================
"
}

show_usage() {
    echo "Usage: ./${SCRIPT_NAME} <destination_ip>"
    echo ""
    echo "Arguments:"
    echo "  destination_ip    IPv4 address of the target machine"
    echo ""
    echo "Options:"
    echo "  -h, --help        Display this help message"
    echo "  --version         Display script version"
}

validate_arguments() {
    local num_args=$#
    local IPV4_REGEX="^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-2][0-9]|[1-9]?[0-9])$"

    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        --version)
            echo "$SCRIPT_NAME version $SCRIPT_VERSION"
            exit 0
            ;;
    esac

    if [[ $num_args -ne 1 ]]; then
        echo "Error: exactly 1 argument required (received: $num_args)." >&2
        show_usage >&2
        exit 1
    fi

    if [[ ! "$1" =~ $IPV4_REGEX ]]; then
        echo "Error: '$1' is not a valid IPv4 address." >&2
        show_usage >&2
        exit 1
    fi
}

check_dependencies() {
    local all_dependencies_available=true
    local tool

    for tool in "ip" "ping" "tcpdump" "sudo" "awk"; do
        if ! command -v "$tool" > /dev/null 2>&1; then
            echo "$tool is not installed. Install it and run $SCRIPT_NAME again." >&2
            all_dependencies_available=false
        fi
    done

    if [[ "$all_dependencies_available" == false ]]; then
        exit 1
    fi
}

discover_network_interface() {
    local destination_ip="$1"
    local network_interface

    if ! network_interface=$(ip route get "$destination_ip" | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}'); then
        echo "Failed to determine the route to ${destination_ip}." >&2
        return 1
    fi

    if [[ -z "$network_interface" ]]; then
        echo "Network interface could not be detected. Check the routing configuration." >&2
        return 1
    fi

    echo "$network_interface"
}

inspect_arp_cache() {
    local destination_ip="$1"
    local network_interface="$2"
    local arp_table

    if ! arp_table=$(ip neigh show "$destination_ip" dev "$network_interface"); then
        echo "Failed to inspect ARP cache for ${destination_ip}." >&2
        return 1
    fi

    if [[ -n "$arp_table" ]]; then
        echo "Current ARP cache entry:"
        echo "$arp_table"
    else
        echo "No existing ARP cache entry found for ${destination_ip}."
    fi
}

remove_arp_cache_entry() {
    local destination_ip="$1"
    local network_interface="$2"
    local arp_entry

    if ! arp_entry=$(ip neigh show "$destination_ip" dev "$network_interface"); then
        echo "Failed to inspect ARP cache before removal." >&2
        return 1
    fi

    if [[ -z "$arp_entry" ]]; then
        echo "No ARP cache entry found for ${destination_ip} on ${network_interface}. Nothing to remove."
        return 0
    fi

    if sudo ip neigh del "$destination_ip" dev "$network_interface"; then
        echo "ARP cache entry for ${destination_ip} on ${network_interface} successfully removed."
    else
        echo "Failed to remove ARP cache entry for ${destination_ip} on ${network_interface}." >&2
        return 1
    fi
}

start_packet_capture() {
    local network_interface="$1"

    echo "Starting packet capture on ${network_interface}..."

   
    sudo tcpdump -i "$network_interface" -nn -U -w "$CAPTURE_FILE" arp &
    CAPTURE_PID=$!

    sleep 1

    if ! kill -0 "$CAPTURE_PID" 2>/dev/null; then
        wait "$CAPTURE_PID" || true
        CAPTURE_PID=""
        echo "Failed to start packet capture." >&2
        return 1
    fi

    echo "Packet capture started. PID: ${CAPTURE_PID}"
}

generate_network_traffic() {
    local destination_ip="$1"

    echo "Generating network traffic to ${destination_ip}..."

    if ping -c 4 -W 2 "$destination_ip"; then
        echo "Ping completed successfully."
    else
        echo "Ping received no response or encountered an error. Check the capture for ARP traffic." >&2
    fi
}

stop_packet_capture() {
    if [[ -z "$CAPTURE_PID" ]]; then
        return 0
    fi

    echo "Stopping packet capture..."

    if sudo kill -INT "$CAPTURE_PID" 2>/dev/null; then
        if wait "$CAPTURE_PID"; then
            echo "Packet capture stopped successfully."
            CAPTURE_PID=""
        else
            CAPTURE_PID=""
            echo "Packet capture exited with an error." >&2
            return 1
        fi
    else
        wait "$CAPTURE_PID" || true
        CAPTURE_PID=""
        echo "Could not signal the packet capture process." >&2
        return 1
    fi
}

show_results() {
    echo ""
    echo "============================="
    echo "       Experiment Results"
    echo "============================="

    if [[ ! -s "$CAPTURE_FILE" ]]; then
        echo "No packet capture data found." >&2
        return 1
    fi

    echo "Capture file: ${CAPTURE_FILE}"
    echo ""
    echo "Captured ARP packets:"
    echo ""

    tcpdump -nn -r "$CAPTURE_FILE"
}


# ------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------

main() {

    validate_arguments "$@"

    local destination_ip="$1"
    local network_interface

    show_banner

    check_dependencies

    if ! sudo -v; then
        echo "Sudo authentication failed." >&2
        exit 1
    fi

    network_interface=$(discover_network_interface "$destination_ip") || exit 1

    inspect_arp_cache "$destination_ip" "$network_interface" || exit 1

    remove_arp_cache_entry "$destination_ip" "$network_interface" || exit 1

    start_packet_capture "$network_interface" || exit 1

    trap 'stop_packet_capture || true' EXIT

    generate_network_traffic "$destination_ip"

    stop_packet_capture

    trap - EXIT

    show_results
}

main "$@"
