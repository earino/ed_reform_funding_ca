ed_reform_funding_ca
====================

in scripts directory, find perl scripts used to massage source data
in images directory, find dendograms of funder similarity clustering in 6 dimensional space
in data directory, find original data as well as computed data

variableized:

```R
dist.variableized <- dist(variableized[,2:6])
 
variableized.link<-hclust(dist.variableized, method='ward')
 
plclust(variableized.link)
```

means:

```R
dist.means <- dist(mean_funding[,2:6])

means.link<-hclust(dist.means, method='ward')

plclust(means.link)
```
