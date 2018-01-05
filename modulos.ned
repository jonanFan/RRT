simple Fuente
{
    parameters:
        int lambda = default(1000);
        int startTime = default(20);
        double tamPaquete = default(1024);

        @display("i=block/source");
    gates:
        output down_layer;
}

simple Receptor
{				
        @display("i=block/sink");
    gates:
        input down_layer;
}

simple ReceptorTransporte
{
    parameters:
        int lenACK= default(1);
		int puerto=default(0);
		
        @display("i=block/transport");
    gates:
        output up_layer;
        inout down_layer;
}

simple TransmisorDummy
{
    parameters:
		int header_tam= default(10);
		int puerto=default(0);
		int dstPuerto=default(0);
		
        @display("i=block/transport");
    gates:
        input up_layer;
        inout down_layer;
}

channel Canal extends ned.DatarateChannel
{
    @class(Canal);
    double packetLoss = default(0);  
}
