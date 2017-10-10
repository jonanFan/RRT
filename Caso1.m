(* ::Package:: *)

(* ::Input:: *)
(*<< "/home/juanan/Escritorio/Armando/Mathematica/Cosas de git/RRT/RandomData.m"*)


(* ::Input:: *)
(*nmuestras=10000;*)
(*ro=0.8;*)
(*mu=100;*)
(*lamda=100*ro; (*Tiempo del paquete es 1/lambda *)*)


(* ::Input:: *)
(*arrayUniform=Table[RandomData[], {i,nmuestras}];*)
(*Histogram[arrayUniform]*)


(* ::Input:: *)
(**)
(*arrayExp=Table[RandomExp[lamda], {i,nmuestras}];*)
(*Histogram[arrayExp,lamda,CDF]*)


(* ::Input:: *)
(*(* Esto te da los elementos que hay entre el 50 y el 100 --> arrayExp[[50;;100]] *)*)


(* ::Input:: *)
(*(* Esto te dice la info del paquete ?RandomData`* *)*)


(* ::Input:: *)
(*interArrivals=Table[RandomExp[lamda], nmuestras];*)
(*(* Esto te da los tiempos entre llegadas *)*)
(*interArrivals[[1;;10]]*)


(* ::Input:: *)
(*arrivals = Accumulate[interArrivals];*)
(*(* Suma todos los interarrivals anteriores *)*)
(*arrivals[[1;;10]]*)


(* ::Input:: *)
(*serviceTime=Table[RandomExp[mu], nmuestras];*)
(*serviceTime[[1;;10]]*)


(* ::Input:: *)
(*(*FifoSchedulling[arrivals_,service_]:=Module[{n,checkTime},n=1;checkTime=arrivals[[1]];*)
(*(If[checkTime\[GreaterEqual]#,checkTime+=service[[n++]],checkTime=#+service[[n++]]])&/@arrivals]*)*)
(*(* Todo lo que acaba a ; es una lista de comandos o algo asi, primero inicializa n igual a 1, luego pone checkTime al primer valor de arrivals, y luego con el MAP recorre arrivals y ejecuta el codigo del bloque.*)
(*El # indica el valor del elemento del array en el que se encuentra la iteracion*)*)
(*FifoSchedulling[arrivals_,service_]:=Module[{n,checkTime},n=1;checkTime=arrivals[[1]];*)
(*Map[(If[checkTime>=#,checkTime+=service[[n++]],checkTime=#+service[[n++]]])&,arrivals]]*)


(* ::Input:: *)
(*departure=FifoSchedulling[arrivals, serviceTime];*)
(*departure[[1;;10]]*)


(* ::Input:: *)
(*ListPlot[{arrivals[[1;;20]],departure[[1;;20]]}]*)


(* ::Input:: *)
(*(* M/M/Colas de salida/Numero de usuarios. Por ejemplo, si hay 2 colas y 3 usuarios eso significa que hay 1 en cada cola y otro esperando *)*)


(* ::Input:: *)
(*(*Manipulate*)
(*[ListLinePlot[{LineStairStep[StairStepArrivals[[origin;;origin+width]]],LineStairStep[StairStepDepartures[[origin;;origin+width]]]},AxesOrigin\[Rule]{StairStepArrivals[[origin]][[1]],StairStepArrivals[[origin]][[2]]-1}],{origin,1,nmax,1,Appearance\[Rule]"*)
(*Labeled*)
(*"},{width,10,100,1}]*)*)


(* ::Input:: *)
(*Manipulate[ListPlot[{arrivals[[origin;;origin+width]],departure[[origin;;origin+width]]}], {origin, 1, 1000-width,1}, {width, 10,50, 1}]*)


(* ::Input:: *)
(*(*Esto lo suyo seria hacer la escalera y dibujar los escalones y como sube*)
(*OJO CUIDADO!!! HABRIA QUE CAMBIAR LOS EJES*)*)


(* ::Input:: *)
(*(* IDEA FELIZ DE ESCALERA *)*)
(*a={1,2,3,4,5,6,7};*)
(*PointStep[list_]:= Module[{n=0,m=0},Flatten[ Map[{{n,m},{n+1,m=#}} &, list],1]];*)


(* ::Input:: *)
(*PointStep[a]*)
