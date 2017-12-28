simple Fuente
{
    parameters:
        int lambda = default(1000);
        int startTime = default(20);
        double tamPaquete = default(1024);

        @display("i=block/source");
    gates:
        output out;
}

simple Receptor
{
    parameters:
        double probACKLoss = default(0);
        double probPacketLoss = default(0);
		double lenACK= default(1);
		
        @display("i=block/sink");
    gates:
        input in;
        output out;
}

simple StopWait
{      
    parameters:
        double lenACK= default(1);
          
    @display("i=block/queue");

    gates:
        input paquetes;
        input in;
        output out;
}

simple GBN
{
    parameters:
        int	tamVentana = default(8);
        double lenACK= default(1);
        
    @display("i=block/queue");
    gates:
        input paquetes;
        input in;
        output out;
}
