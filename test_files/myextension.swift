import assert;

@dispatch=WORKER
dowork (int i) "myextension" "1.0" [
  "puts [ myextension::makestatement <<i>> ]"
];

trace("adlb servers: " + adlb_servers());
trace("turbine workers: " + turbine_workers());

dowork(8);
dowork(9);
dowork(10);
dowork(11);
dowork(12);
dowork(13);
dowork(14);
