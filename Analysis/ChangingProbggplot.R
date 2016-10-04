plotDat <- read.csv("~/Documents/Lab/Landy/SDT-Changing-Probabilities/Mixed-Design/Data/SDTChangingProbabilitiesMixed_HHL.csv",header = TRUE)
subName <- "HHL"

require("ggplot2")


# path = "~/Documents/Lab/Landy/SDT-Changing-Probabilities/Mixed-Design/Data/"
# setwd(path)
# file.names <- dir(pattern ="*.csv")
# # 
#  for(s in 1:length(file.names)){
#   
#   plotDat <- read.csv(file.names[s], header = TRUE)
#    subName <- substr(file.names[s],31,33)
#yrange <- c(min(plotDat[,c("estCrit","obsCrit")], na.rm = TRUE),max(plotDat[,c("estCrit","obsCrit")],na.rm = TRUE))

#dev.new(width = 10, height = 6)
gp <- ggplot() +
  geom_line(data = plotDat, aes(x = trial, y = omCrit, linetype="Omniscient")) +
  geom_point(data = plotDat, aes(x=OvTrial,y=obsCrit, colour='Overt'), shape=1) +
  geom_point(data = plotDat, aes(x=wind,y=estCrit, colour='Covert'), shape=1) + 
  scale_x_continuous(expand = c(0.005,1)) + scale_y_continuous(expand = c(.1, 0.01)) + # I have no idea what these numbers actually do
  theme_bw() +  theme(plot.background = element_blank(), panel.border = element_blank(), plot.margin=unit(c(1.5,0,1,1),"cm")) +
  scale_colour_manual("", breaks = c("Overt", "Covert"), values = c("blue", "red")) +
  scale_linetype_manual("", breaks= "Omniscient", values="dashed") +
  labs(title=subName, x = "Trial", y = "Criterion (degrees)") 
gp

filename = paste(subName, "critbytrial.png", sep = "_")
ggsave(filename=filename, plot=gp, width = 10, height = 6) 

# om.crit.rng <- c(min(plotDat$omCrit)-25,max(plotDat$omCrit)+25)
yrange <- c(min(plotDat[,c("estCrit","obsCrit")], na.rm = TRUE),max(plotDat[,c("estCrit","obsCrit")],na.rm = TRUE))

# Axis sizes kept constant at difference of 70

# om.crit.rng  <- c(-10,100) 
# yrange <- c(-100,100)

#dev.new(width = 6, height = 6)
gp2 <- ggplot() +
  geom_point(data = plotDat, aes(x=OvOmCrit,y=obsCrit, colour = "Overt"), shape=1) +
  geom_point(data = plotDat, aes(x=CovOmCrit,y=estCrit, colour = "Covert"), shape=1) +
  geom_smooth(data = plotDat, aes(x=OvOmCrit, y=obsCrit, colour = "Overt"), size = 0.5, se = FALSE, method = lm, fullrange = TRUE) +
  geom_smooth(data = plotDat, aes(x=CovOmCrit, y=estCrit, colour = "Covert"), size = 0.5, se = FALSE, method = "lm", fullrange = TRUE) +
  geom_line(aes(x=(-150:200), y=(-150:200), linetype = "Omniscient"), colour = "grey") +
  #geom_abline(aes(x=(-150:200), y=(-150:200)), linetype = "dashed", intercept = 0, slope = 1) + 
  scale_x_continuous(expand = c(0,0), limits=yrange) + scale_y_continuous(expand = c(0,0), limits=yrange) + 
  theme_bw() +  theme(plot.background = element_blank(), plot.margin=unit(c(1,0,1,1),"cm")) +
  scale_colour_manual("", breaks=c("Overt","Covert"), values=c("blue","red")) +
  scale_linetype_manual("", breaks=c("Omniscient","Covert","Overt"), values=c("dashed","solid","solid")) +
  labs(title=subName, x="Omniscient Criterion", y="Observed Criterion") 

gp2
filename = paste(subName, "obsVom.png", sep = "_")  
ggsave(filename=filename, plot=gp2, width = 6, height = 6)

}

