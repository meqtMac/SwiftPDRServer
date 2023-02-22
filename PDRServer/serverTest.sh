#!/usr/bin/zsh
swift run Run routes
vapor run migrate --revert
vapor run migrate
testpath="testpath"$(date)
mkdir $testpath
port=8888
PID=$(lsof -t -i:$port )
if [ -z "$PID" ]; then
    echo "No process running on port $port"
else
    echo "port:$port already in use"
    exit
fi
vapor run serve --port $port > "$testpath"/vapor_log_8888.txt &

sleep 5

for path in [runnings, positions, runnings/pdr]
do
    for batch in [27, 28, 29]
    do
        curl "http://localhost:$port/$path\?batch\=$batch" > "$testpath"/"$path$batch.json"
    done
done

curl "http://localhost:$port/runnings/train\?k\=0.4\&m\=0.08\&dk\=0.01\&dm\=0.001\&eta\=0.000002\&epochs\=1000"

PID=$(lsof -t -i:$port)
if [ -z "$PID" ]; then
    echo "No process running on port $port"
else
    kill $PID
    echo "Process $PID killed"
fi
