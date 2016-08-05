plotDat <- read.csv("~/Documents/Lab/Landy/SDT_Changing_Probabilities/Mixed_Design/Data/SDTplot.csv",header = TRUE)


require("ggplot2")


# path = "~/Documents/Lab/Landy/SDT_Changing_Probabilities/Mixed_Design/Data/"
# file.names <- dir(path, pattern ="*.csv")
# 
# for(s in 1:length(file.names)){

#yrange <- c(min(plotDat[,c("estCrit","obsCrit")], na.rm = TRUE),max(plotDat[,c("estCrit","obsCrit")],na.rm = TRUE))

dev.new(width = 10, height = 6)
gp <- ggplot() +
  geom_line(data = plotDat, aes(x = trial, y = omCrit, linetype="Omniscient")) +
  geom_point(data = plotDat, aes(x=OvTrial,y=obsCrit, colour='Overt'), shape=1) +
  geom_point(data = plotDat, aes(x=wind,y=estCrit, colour='Covert'), shape=1) + 
  scale_x_continuous(expand = c(0.005,1)) + scale_y_continuous(expand = c(.1, 0.01)) + # I have no idea what these numbers actually do
  theme_bw() +  theme(plot.background = element_blank(), panel.border = element_blank(), plot.margin=unit(c(0,0,1,1),"cm")) +
  scale_colour_manual("", breaks = c("Overt", "Covert"), values = c("blue", "red")) +
  scale_linetype_manual("", breaks= "Omniscient", values="dashed") +
  labs(x = "Trial", y = "Criterion (degrees)") 
gp


om.crit.rng <- c(min(plotDat$omCrit)-25,max(plotDat$omCrit)+25)
yrange <- c(min(plotDat[,c("estCrit","obsCrit")], na.rm = TRUE),max(plotDat[,c("estCrit","obsCrit")],na.rm = TRUE))

gp2 <- ggplot() +
  geom_point(data = plotDat, aes(x=OvOmCrit,y=obsCrit, colour = "Overt"), shape=1) +
  geom_point(data = plotDat, aes(x=CovOmCrit,y=estCrit, colour = "Covert"), shape=1) +
  geom_smooth(data = plotDat, aes(x=OvOmCrit, y=obsCrit, colour = "Overt"), size = 0.5, se = FALSE, method = lm, fullrange = TRUE) +
  geom_smooth(data = plotDat, aes(x=CovOmCrit, y=estCrit, colour = "Covert"), size = 0.5, se = FALSE, method = "lm", fullrange = TRUE) +
  geom_line(aes(x=(-150:200), y=(-150:200), linetype = "Omniscient"), colour = "grey") +
  #geom_abline(aes(x=(-150:200), y=(-150:200)), linetype = "dashed", intercept = 0, slope = 1) + 
  scale_x_continuous(expand = c(0,0), limits=om.crit.rng) + scale_y_continuous(expand = c(.1,0.01), limits=yrange) + 
  theme_bw() +  theme(plot.background = element_blank(), plot.margin=unit(c(0,0,1,1),"cm")) +
  scale_colour_manual("", breaks=c("Overt","Covert"), values=c("blue","red")) +
  scale_linetype_manual("", breaks=c("Omniscient","Covert","Overt"), values=c("dashed","solid","solid")) +
  labs(x="Omniscient Criterion", y="Observed Criterion")

gp2
  