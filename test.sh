docker build -q -t stax .
docker run --rm --name stax -d -p 8080:8080 -e WRITE_MEMORY_API=http://localhost:8080/api/v1/debug/writeMemory stax

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":2,"state":{"a":92,"b":120,"c":66,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":true,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":1}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":2,"state":{"a":92,"b":120,"c":66,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":true,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":8}}'

docker kill stax

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mSTAX Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mSTAX Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi