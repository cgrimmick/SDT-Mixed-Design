# SDT Plot 

plotDat <- read.csv("~/Documents/MATLAB/SDT_Changing_Probabilities/Mixed_Design/Data/SDTplot.csv",header = TRUE)

x <- plotDat$trial
y <- plotDat$omCrit
x1 <- plotDat$wind
y1 <- plotDat$estCrit
x2 <- plotDat$OvTrial
y2 <- plotDat$obsCrit

plot(x1,y1, main = "SDT", col=4, xlim=c(0, 1200),ylim=c(-20, 95))
lines(x,y, type = "l")
#points(x1,y1, col=2)
points(x2,y2,col=2)
