// simple wrapper for websocket so that there is a better read and write function and also wait for the socet to open up 
// Joseph Mills <josephjamesmills@gmail.com>
var ws;
var goldenString;
var currentCommand;
function makeConnection(){
   ws = new WebSocket("ws://localhost:8088/");
   ws.onmessage = function(event) {
        goldenString = event.data;
	};
}
function sendMessage(msg){
    // Wait until the state of the socket is not ready and send the message when it is...
    waitForSocketConnection(ws, function(){
//        console.log("message sent!!!");
        ws.send(msg);
    });
}

// Make the function wait until the connection is made...
function waitForSocketConnection(socket, callback){
    setTimeout(
        function () {
            if (socket.readyState === 1) {
                //console.log("Connection is made")
                if(callback != null){
                    callback();
                }
                return;

            } else {
                //console.log("wait for connection...")
                waitForSocketConnection(socket, callback);
            }

        }, 1); // wait 5 milisecond for the connection...
}
