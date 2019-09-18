# !/bin/sh

export PGPLOT_DIR=/usr/local/pgplot
export PGPLOT_SRC=/usr/local/src/pgplot

cd $PGPLOT_SRC

cd pgplot/drivers
patch < /home/ittipat/src/psrchive/packages/pndriv.patch

cd ../sys_linux
cp g77_gcc_aout.conf psrchive.conf

perl -pi -e "s/g77//usr/bin/gfortran/" psrchive.conf
perl -pi -e 's/-u //' psrchive.conf
perl -pi -e 's|-I/usr/X11R6/include||' psrchive.conf
perl -pi -e 's|-L/usr/X11R6/lib|/usr/lib64|' psrchive.conf

cd $PGPLOT_DIR
cp $PGPLOT_SRC/drivers.list .
perl -pi -e 's/! PNDRIV/  PNDRIV/' drivers.list
perl -pi -e 's/! PSDRIV/  PSDRIV/' drivers.list
perl -pi -e 's/! XWDRIV/  XWDRIV/' drivers.list
$PGPLOT_SRC/makemake $PGPLOT_SRC linux psrchive
perl -pi -e 's/^pndriv\.o :/# /' makefile
make
make cpg
make pgxwin_server
make grfont.dat

