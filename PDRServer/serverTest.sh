#!/usr/bin/zsh
swift run Run routes
vapor run migrate --revert
vapor run migrate
testpath="testpath"$(date)
mkdir "$testpath"
PID=$(lsof -t -i:8888)

if [ -z "$PID" ]; then
  echo "No process running on port 8080"
else
# Kill the process using the PID
kill $PID
echo "Process $PID killed"
fi
vapor run serve --port 8888 > "$testpath"/vapor_log_8888.txt & 

sleep 5

curl http://localhost:8888/runnings/train\?k\=0.4\&m\=0.08\&dk\=0.01\&dm\=0.001\&eta\=0.000002\&epochs\=1000
curl http://localhost:8888/runnings/pdr\?batch\=29 > "$testpath"/pdr29.json
curl http://localhost:8888/runnings/pdr\?batch\=28 > "$testpath"/pdr28.json
curl http://localhost:8888/runnings/pdr\?batch\=27 > "$testpath"/pdr27.json
curl http://localhost:8888/runnings\?batch\=27 > "$testpath"/runnings27.json
curl http://localhost:8888/runnings\?batch\=28 > "$testpath"/runnings28.json
curl http://localhost:8888/runnings\?batch\=29 > "$testpath"/runnings29.json
curl http://localhost:8888/positions\?batch\=29 > "$testpath"/positions29.json
curl http://localhost:8888/positions\?batch\=28 > "$testpath"/positions28.json
curl http://localhost:8888/positions\?batch\=27 > "$testpath"/positions27.json

PID=$(lsof -t -i:8888)

if [ -z "$PID" ]; then
  echo "No process running on port 8080"
else
  # Kill the process using the PID
  kill $PID
  echo "Process $PID killed"
fi
