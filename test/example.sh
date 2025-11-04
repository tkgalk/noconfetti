#!/usr/bin/env bash
# Shell Script Example - System Administration and DevOps
# Testing: comments, strings, variables, functions, control flow

set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Constants and configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/app.log"
readonly MAX_RETRIES=3
readonly TIMEOUT=30
readonly API_VERSION="v1.0"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

#######################################
# Print colored message
# Arguments:
#   $1 - Color code
#   $2 - Message
#######################################
print_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

#######################################
# Log message with timestamp
# Arguments:
#   $1 - Log level
#   $2 - Message
#######################################
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
}

#######################################
# Check if command exists
# Arguments:
#   $1 - Command name
# Returns:
#   0 if command exists, 1 otherwise
#######################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#######################################
# Validate input parameters
# Arguments:
#   $1 - Parameter name
#   $2 - Parameter value
#######################################
validate_input() {
    local param_name="$1"
    local param_value="$2"

    if [[ -z "$param_value" ]]; then
        print_color "$RED" "Error: ${param_name} cannot be empty"
        exit 1
    fi
}

#######################################
# Create user in the system
# Arguments:
#   $1 - Username
#   $2 - Email
#   $3 - Age
#######################################
create_user() {
    local username="$1"
    local email="$2"
    local age="$3"

    validate_input "username" "$username"
    validate_input "email" "$email"

    # Check if user already exists
    if id "$username" &>/dev/null; then
        print_color "$YELLOW" "Warning: User ${username} already exists"
        return 1
    fi

    # Create user
    if useradd -m -s /bin/bash "$username"; then
        log "INFO" "Created user: ${username}"
        print_color "$GREEN" "Successfully created user: ${username}"
        return 0
    else
        log "ERROR" "Failed to create user: ${username}"
        print_color "$RED" "Failed to create user: ${username}"
        return 1
    fi
}

#######################################
# Backup directory with compression
# Arguments:
#   $1 - Source directory
#   $2 - Backup destination
#######################################
backup_directory() {
    local source="$1"
    local dest="$2"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${dest}/backup_${timestamp}.tar.gz"

    if [[ ! -d "$source" ]]; then
        print_color "$RED" "Error: Source directory does not exist: ${source}"
        return 1
    fi

    mkdir -p "$dest"

    log "INFO" "Starting backup of ${source}"
    if tar -czf "$backup_file" -C "$(dirname "$source")" "$(basename "$source")"; then
        log "INFO" "Backup completed: ${backup_file}"
        print_color "$GREEN" "Backup saved to: ${backup_file}"
        return 0
    else
        log "ERROR" "Backup failed for ${source}"
        return 1
    fi
}

#######################################
# Fetch data from API with retry logic
# Arguments:
#   $1 - API endpoint URL
#######################################
fetch_api_data() {
    local url="$1"
    local retry_count=0

    while [[ $retry_count -lt $MAX_RETRIES ]]; do
        log "INFO" "Fetching data from ${url} (attempt $((retry_count + 1)))"

        if response=$(curl -s -f -m "$TIMEOUT" "$url"); then
            print_color "$GREEN" "Successfully fetched data"
            echo "$response"
            return 0
        fi

        ((retry_count++))
        print_color "$YELLOW" "Retry $retry_count/$MAX_RETRIES failed"
        sleep 2
    done

    print_color "$RED" "Failed to fetch data after ${MAX_RETRIES} attempts"
    return 1
}

#######################################
# Process log files
#######################################
process_logs() {
    local log_dir="/var/log"
    local search_term="$1"

    # Find and process log files
    find "$log_dir" -name "*.log" -type f | while read -r logfile; do
        if [[ -r "$logfile" ]]; then
            local count=$(grep -c "$search_term" "$logfile" 2>/dev/null || echo 0)
            if [[ $count -gt 0 ]]; then
                echo "Found $count occurrences in $(basename "$logfile")"
            fi
        fi
    done
}

#######################################
# Check system resources
#######################################
check_system_resources() {
    print_color "$BLUE" "=== System Resources ==="

    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "CPU Usage: ${cpu_usage}%"

    # Memory usage
    local mem_total=$(free -m | awk '/Mem:/ {print $2}')
    local mem_used=$(free -m | awk '/Mem:/ {print $3}')
    local mem_percent=$((mem_used * 100 / mem_total))
    echo "Memory: ${mem_used}MB / ${mem_total}MB (${mem_percent}%)"

    # Disk usage
    df -h | grep -E '^/dev/' | awk '{print $1 " " $5 " " $6}'
}

#######################################
# Array operations
#######################################
demonstrate_arrays() {
    # Indexed array
    local numbers=(1 2 3 4 5)
    echo "Numbers: ${numbers[*]}"

    # Associative array (requires bash 4+)
    declare -A user_info
    user_info[name]="Alice"
    user_info[email]="alice@example.com"
    user_info[age]=28

    echo "User: ${user_info[name]}, ${user_info[email]}"

    # Loop through array
    for num in "${numbers[@]}"; do
        echo "Number: $num"
    done

    # Array operations
    numbers+=(6 7 8)  # Append
    echo "Extended: ${numbers[*]}"
    echo "Length: ${#numbers[@]}"
}

#######################################
# String operations
#######################################
demonstrate_strings() {
    local text="Hello, World!"

    # String length
    echo "Length: ${#text}"

    # Substring
    echo "Substring: ${text:0:5}"

    # Replace
    echo "Replace: ${text/World/Bash}"

    # Upper/lowercase
    echo "Upper: ${text^^}"
    echo "Lower: ${text,,}"

    # Split string
    IFS=',' read -ra parts <<< "one,two,three"
    for part in "${parts[@]}"; do
        echo "Part: $part"
    done
}

#######################################
# Main function
#######################################
main() {
    print_color "$BLUE" "Starting script..."

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --backup)
                backup_directory "$2" "$3"
                shift 3
                ;;
            --check-resources)
                check_system_resources
                shift
                ;;
            --demo-arrays)
                demonstrate_arrays
                shift
                ;;
            --demo-strings)
                demonstrate_strings
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --backup <source> <dest>  Backup directory"
                echo "  --check-resources         Check system resources"
                echo "  --demo-arrays            Demonstrate arrays"
                echo "  --demo-strings           Demonstrate strings"
                exit 0
                ;;
            *)
                print_color "$RED" "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    print_color "$GREEN" "Script completed successfully"
}

# Run main function with all arguments
main "$@"
