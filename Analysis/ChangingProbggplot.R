
require("ggplot2")

# !!! Because of loop, currently doesn't print the figures out for each subject

path = "~/Documents/Lab/Landy/SDT-Changing-Probabilities/Mixed-Design/Data/"
setwd(path)
subj = toupper(readline(prompt = "Subject initials (ALL for all files): "))
if(subj=="ALL"){
  file.names <- dir(pattern ="*.csv")
} else {
  file.names  <- dir(pattern = paste(subj,"*.csv"))
}

save_opt = toupper(readline(prompt = "Save plots to file? "))

for(s in 1:length(file.names)){
   
  plotDat <- read.csv(file.names[s], header = TRUE)
  subName <- substr(file.names[s],31,33)
#yrange <- c(min(plotDat[,c("estCrit","obsCrit")], na.rm = TRUE),max(plotDat[,c("estCrit","obsCrit")],na.rm = TRUE))

dev.new(width = 10, height = 6)
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

  if(save_opt=="Y"){
    filename = paste(subj, "critbytrial.png", sep = "_")
     ggsave(filename=filename, plot=gp, width = 10, height = 6) 
  }
# om.crit.rng <- c(min(plotDat$omCrit)-25,max(plotDat$omCrit)+25)
yrange <- c(min(plotDat[,c("estCrit","obsCrit")], na.rm = TRUE),max(plotDat[,c("estCrit","obsCrit")],na.rm = TRUE))

# Axis sizes kept constant at difference of 70

# om.crit.rng  <- c(-10,100) 
# yrange <- c(-100,100)

dev.new(width = 6, height = 6)
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

  if(save_opt=="Y"){
    filename = paste(subName, "obsVom.png", sep = "_")  
    ggsave(filename=filename, plot=gp2, width = 6, height = 6)
  }


dev.new(width = 11, height = 6)
gp3 <- ggplot() +
  geom_point(data = plotDat, aes(x = CovTrial, y=catResp, shape = "Response"), colour = "blue", size = 2) +
  geom_line(data = plotDat, aes(x=CovTrial, y=smoothCatResp, colour = "P(Choose A)")) +
  geom_line(data = plotDat, aes(x= OvTrial, y= smoothpA_obs, colour = "P(A) Obs")) +
  geom_line(data = plotDat, aes(x = trial, y = smoothProbA, linetype = "True P(A)")) + 
  scale_x_continuous(expand = c(0,0), limits=c(1,1200)) + scale_y_continuous(expand = c(0,0), limits=c(0,1)) + 
  theme_bw() +  theme(plot.background = element_blank(), plot.margin=unit(c(1,0,1,1),"cm")) +
  scale_shape_manual("", breaks= "Response", values=1) + # would be good to change transparency
  scale_colour_manual("", breaks=c("P(A) Obs","P(Choose A)"), values=c("red","blue")) +
  scale_linetype_manual("", breaks=c("True P(A)","P(Choose A)","P(A) Obs"), values=c("dashed","solid","solid")) +
  labs(title=subName, x="Trial", y="Probability") 

gp3

  if(save_opt=="Y"){
    filename = paste(subName, "smoothed_probs.png", sep = "_")  
    ggsave(filename=filename, plot=gp3, width = 11, height = 6)
  }


}
