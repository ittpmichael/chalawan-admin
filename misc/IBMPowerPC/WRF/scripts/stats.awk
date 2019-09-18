BEGIN{ a = 0.0 ; i = 0 ; i2 = 0; i3 = 0; b = 0.0; max = -999999999  ; min = 9999999999 }
{
    i ++ 
    if ( i > 0 ) {
       b += $1
       i3 ++
    }
# skip first time step which includes I/O for t=0
    if ( i > 1) {
#   if ( $1 < 0.29) {
    i2 ++
    a += $1
    if ( $1 > max ) max = $1
    if ( $1 < min ) min = $1
#   }
    }
#   printf("%d, %d, %d, %f, %f, %f\n", i, i3, i2, $1, b, a); 
}
# and last
END{ i = i2; printf("Non-I/O steps---\n%10s  %8d\n%10s  %15f\n%10s  %15f\n%10s  %15f\n%10s  %15f\n%10s  %15f\n","steps:",i,"max:",max,"min:",min,"sum:",a,"mean:",a/(i*1.0),"mean/max:",(a/(i*1.0))/max); printf("\nAll time steps ---\n%8d, sum: %15f, mean: %15f\n",i3,b,(b/(i3*1.0))) }
