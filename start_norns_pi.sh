#/bin/bash

# start screen
#Xvfb :0 -screen 0 1280x640x16 -fbdir /tmp &
sleep 1
cd $HOME/norns-desktop
LOGGER=info /usr/local/go/bin/go run oled-server.go -window-name 'matron' -port 8889 &
#sleep 1

# start jack
export JACK_NO_START_SERVER=1
export JACK_NO_AUDIO_RESERVATION=1
export JACK_AUDIO=$(aplay -l | head -n1 | grep USB | sed 's/:/ /g' | awk '{print $2}')
#/usr/bin/jackd -R -P 95 -d alsa -P hw:$JACK_AUDIO -i 2 & # playback only
#/usr/bin/jackd -R -P 95 -d alsa -d hw:$JACK_AUDIO -p 1024 & # 2x2 USB interface
/usr/bin/jackd -t 2000 -R -P 95 -d alsa -d hw:pisound -r 48000 &

sleep 1

# start crone
$HOME/norns/build/crone/crone &

# start sc
$HOME/norns/build/ws-wrapper/ws-wrapper 'ws://*:5556' /usr/local/bin/sclang -i maiden &

# start matron 
#export DISPLAY=:0
#xrandr --output DSI-1 --mode 800x480 --scale 1x1
$HOME/norns/build/ws-wrapper/ws-wrapper 'ws://*:5555' $HOME/norns/build/matron/matron &
#xprop -name 'matron' -format _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS 2 
#wmctrl -r ':ACTIVE:' -b toggle,fullscreen

# start maiden
cd $HOME/maiden && ./maiden server --app ./app/build --data ~/dust --doc ~/norns/doc &

# optional, start icecast
# icecast2 -c $HOME/norns-desktop/icecast.xml &
# sleep 0.5
# darkice -c $HOME/norns-desktop/darkice.cfg &
# sleep 0.5
# jack_connect crone:output_1 darkice:left
# jack_connect crone:output_2 darkice:right
