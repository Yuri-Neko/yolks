#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Get System Information
SYS_OS=$(lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 || uname -om)
SYS_KERNEL=$(uname -r)
SYS_UPTIME=$(uptime -p | sed 's/up //')
SYS_CPU=$(grep -m 1 'model name' /proc/cpuinfo | cut -d':' -f2 | sed 's/^[ \t]*//;s/ *$//')
SYS_CORES=$(nproc)
SYS_CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
SYS_MEM_TOTAL=$(free -m | awk '/Mem:/ {printf "%.1fGi", $2/1024}')
SYS_MEM_USED=$(free -m | awk '/Mem:/ {printf "%.1fGi", $3/1024}')
SYS_DISK=$(df -h / | awk 'NR==2 {printf "%s/%s", $3, $2}')
SYS_DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
SYS_PACKAGES=$(dpkg --get-selections | wc -l)
NODE_VERSION=$(node -v 2>/dev/null || echo "Node.js not installed")

# Get Network Information
HOST_NAME=$(hostname)
PUBLIC_IP=$(curl -s ifconfig.me)
LOCATION_INFO=$(curl -s ipinfo.io/$PUBLIC_IP)
ISP=$(echo "$LOCATION_INFO" | grep -Po '"org":.*?[^\\]",' | cut -d'"' -f4)
COUNTRY=$(echo "$LOCATION_INFO" | grep -Po '"country":.*?[^\\]",' | cut -d'"' -f4)
REGION=$(echo "$LOCATION_INFO" | grep -Po '"region":.*?[^\\]",' | cut -d'"' -f4)
CITY=$(echo "$LOCATION_INFO" | grep -Po '"city":.*?[^\\]",' | cut -d'"' -f4)

# Print System Status with VIP style
echo -e "\e[1m\e[38;5;51mSystem Information\e[0m"
echo -e "\e[38;5;51m===========================\e[0m"
echo -e "\e[38;5;214m++ Hostname \e[0m: $HOST_NAME"
echo -e "\e[38;5;214m++ ISP \e[0m: $ISP"
echo -e "\e[38;5;214m++ Location \e[0m: $CITY, $REGION / $COUNTRY"
echo -e "\e[38;5;214m++ Public IP \e[0m: $PUBLIC_IP"
echo -e "\e[38;5;51m---------------------------------\e[0m"
echo -e "\e[38;5;214m++ OS \e[0m: ${SYS_OS}"
echo -e "\e[38;5;214m++ Kernel \e[0m: ${SYS_KERNEL}"
echo -e "\e[38;5;51m---------------------------------\e[0m"
echo -e "\e[38;5;214m++ CPU \e[0m: ${SYS_CPU}"
echo -e "\e[38;5;214m++ Core \e[0m: ${SYS_CORES} Core(s)"
echo -e "\e[38;5;214m++ Usage CPU \e[0m: ${SYS_CPU_USAGE}"
echo -e "\e[38;5;214m++ Memory \e[0m: ${SYS_MEM_USED} / ${SYS_MEM_TOTAL}"
echo -e "\e[38;5;214m++ Disk (/) \e[0m: ${SYS_DISK} (${SYS_DISK_USAGE})"
echo -e "\e[38;5;214m++ Uptime \e[0m: ${SYS_UPTIME}"
echo -e "\e[38;5;214m++ Packages \e[0m: ${SYS_PACKAGES} (dpkg)"
echo -e "\e[38;5;51m---------------------------------\e[0m"
echo -e "\e[38;5;214m++ Nodejs Version \e[0m: ${NODE_VERSION}"
echo -e "\e[38;5;51m---------------------------------\e[0m"
echo -e "\e[38;5;214m++ Pre-installed Packages \e[0m:"
echo -e "\e[38;5;118m   [✓] ImageMagick - Ready for image processing"
echo -e "\e[38;5;118m   [✓] FFmpeg - Ready for video/audio processing"
echo -e "\e[38;5;118m   [✓] Puppeteer - Ready for browser automation"
echo -e "\e[38;5;118m   [✓] PM2 - Process manager installed"
echo -e "\e[38;5;118m   [✓] Chromium - Browser engine available"
echo -e "\e[38;5;51m---------------------------------\e[0m"
echo ""

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Print Startup Command
echo -e "\e[1m\e[38;5;51mStartup Command\e[0m"
echo -e "\e[38;5;51m===========================\e[0m"
echo -e "\e[38;5;255m${MODIFIED_STARTUP}\e[0m"
echo ""

# Run the Server
eval ${MODIFIED_STARTUP}
