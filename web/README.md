## Yaab web interface

A way to build odroid [ u,x,c] mangoES images from scratch	

Running 
```bash
./runServer	
```

Then point the browser to 
http://localhost:8088

One can ssh into machine and port forward the port 8088 so that they can use re$

```bash
ssh -p <ssh port to host> -L8088:localhost:8088 user@hostnameOrIP
```

Run the runServer script. Then point your browser to 

http://localhost:8088
