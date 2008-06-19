@source=("wall_test.cc","wall.cc","cell.cc","container.cc","container.hh","config.hh","cell.hh","wall.hh");
@range=(10..40);
$tries=3;
$compile='g++ -o wall_test -O3 wall_test.cc -pedantic -Winline --param large-function-growth=600 --param max-inline-insns-single=1000 -fast -Wall';
$executable="./wall_test";

foreach $r (@range) {
	foreach $s (@source) {
		open S,$s or die "Can't open source file: $!";
		open T,">.timingtemp/$s" or die "Can't open temporary file: $!";
		while(<S>) {
			s/NNN/$r/g;
			print T;
		}
		close T;
		close S;
	}
	
	chdir ".timingtemp";
	system $compile;
	$tr=$tu=$ts=0;
	$tr2=$tu2=$ts2=0;
	foreach $t (1..$tries) {
		system "eval time $executable 2>ti";
		open F,"ti" or die "Can't open timing file: $!";<F>;
		<F>=~m/(\d*)m([\d\.]*)s/;$rr=$1*60+$2;$tr+=$rr;$tr2+=$rr*$rr;
		<F>=~m/(\d*)m([\d\.]*)s/;$ru=$1*60+$2;$tu+=$ru;$tu2+=$ru*$ru;
		<F>=~m/(\d*)m([\d\.]*)s/;$rs=$1*60+$2;$ts+=$rs;$ts2+=$rs*$rs;
	}
	$tr/=$tries;$tu/=$tries;$ts/=$tries;
	$tr2=sqrt($tr2/$tries-$tr*$tr);
	$tu2=sqrt($tu2/$tries-$tu*$tu);
	$ts2=sqrt($ts2/$tries-$ts*$ts);
	chdir "..";
	print "$r $tr $tu $ts $tr2 $tu2 $ts2\n";
}
