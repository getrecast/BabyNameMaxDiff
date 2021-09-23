## Non-reactive convenience functions to manipulate data

#data has the following format
# ID
# choice set (1,2,3,4,1,2,3,4,etc)
# column for each baby name
# y column indicating which choise set was selected

#sample data
# one=tibble(id=1, choice_set=1, alternative=1:3, name1=c(1, 0, 0), name2=c(0 ,1, 0),
#             name3=c(0,0, 1), y=c(2,0,0))
#
# data = bind_rows(one, one, one) %>%
#   mutate(choice_set=rep(1:3, each=3), y=if_else(y==0, 0L, choice_set))

estimate_utilities <- function(data){
  #print(as.data.frame(data))
  #save(data, file="Temp.RData")
 ChoiceModelR::choicemodelr(
   as.data.frame(data), xcoding= rep(1, ncol(data)-4),
   mcmc=list(R=10000, use=5000))

  res= read_csv("RBetas.csv") %>%
    setNames(names(data)[c(1, 4:(ncol(data)-1))])
  file.remove("RBetas.csv")
  res
}
