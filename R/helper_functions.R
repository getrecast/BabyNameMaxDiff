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
  #stop("all done")
  # print(data)

 #Attach an extra block to fix choicemodelr's bad
 data=data %>% bind_rows(data %>% slice(1:16) %>%
    mutate(id=1+max(data$id),
           question_set=rep(1:4, each=4),
           across(-c(id:choices, y), ~0),
           y=c(1,0,0,0,2,0,0,0,
               3,0,0,0,4,0,0,0)))
 ChoiceModelR::choicemodelr(
   as.data.frame(data), xcoding= rep(1, ncol(data)-4),
   prior=list(Amu=1),
   mcmc=list(R=3000, use=1000))

  res= read_csv("RBetas.csv") %>%
    setNames(names(data)[c(1, 4:(ncol(data)-1))]) %>%
    filter(id<=2) #remove the extra rows
  file.remove("RBetas.csv")
  res
}
