wiz() {
  local payload
  case "$1" in
    on)
      local dimming="${2:-50}"
      local temp="${3:-3000}"
      if (( dimming < 10 || dimming > 100 )); then
        echo "Brightness must be 10-100"; return 1
      fi
      if (( temp < 2200 || temp > 6500 )); then
        echo "Temp must be 2200-6500K"; return 1
      fi
      payload="{\"method\":\"setPilot\",\"params\":{\"state\":true,\"temp\":$temp,\"dimming\":$dimming}}"
      ;;
    off)
      payload='{"method":"setPilot","params":{"state":false}}'
      ;;
    *)
      echo "Usage: wiz on [brightness 10-100] [temp 2200-6500] | wiz off"
      return 1
      ;;
  esac
  python3 -c "
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
s.sendto('$payload'.encode(), ('255.255.255.255', 38899))
s.close()
"
}
