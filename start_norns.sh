#/bin/bash

export DISPLAY=:0
export JACK_NO_START_SERVER=1
export JACK_NO_AUDIO_RESERVATION=1

sudo /etc/init.d/dbus start
sudo chown -R we:we $HOME/dust
Xvfb :0 -screen 0 1280x640x16 -fbdir /tmp &
sleep 0.5
cd $HOME && LOGGER=info /usr/local/go/bin/go run oled-server.go -window-name 'matron' -port 8889 &
sleep 0.5
jackd -V
$(cat /etc/jackdrc) &
sleep 0.5
$HOME/norns/build/crone/crone &
cd $HOME/norns/sc
sleep 0.5
timeout 0.5 $HOME/norns/build/ws-wrapper/ws-wrapper ws://*:5556 /usr/local/bin/sclang -i maiden
sleep 0.5
$HOME/norns/build/ws-wrapper/ws-wrapper ws://*:5556 /usr/local/bin/sclang -i maiden &
sleep 0.5
$HOME/norns/build/ws-wrapper/ws-wrapper ws://*:5555 $HOME/norns/build/matron/matron &
sleep 0.5
cd $HOME/maiden && ./maiden server --app ./app/build --data ~/dust --doc ~/norns/doc &
sleep 0.5
icecast2 -c /etc/icecast2/icecast.xml &
sleep 0.5
darkice -c /etc/darkice.cfg &
sleep 0.25
jack_connect crone:output_1 darkice:left
jack_connect crone:output_2 darkice:right
tail -f /dev/null # stay alive
