package animation;

enum abstract Flag(Int) from Int to Int {
	var GROUNDED    = 0x1;
	var RUNNING     = 0x1 << 1;
	var DODGING  = 0x1 << 2;
}