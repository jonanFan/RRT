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
		double lenACK= default(1);
		
        @display("i=block/sink");
    gates:
        input receiver;
}

channel Canal extends ned.DatarateChannel
{
    @class(Canal);
    double packetLoss = default(0);  
}
