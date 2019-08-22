# Set working directory to "wisdom-of-crowds/src/"
library(dplyr)
library(readr)


clean_data <- function(df_orig){
  # Processes data and prints statistics at each processing step.
  # 
  # @param df_orig: The original data frame to be processed.
  # @return df: The clean, processed dataframe.
  
  cat(sprintf('Responses: %s\n', nrow(df_orig)))
  cat(sprintf('Domains: %s\n', length(unique(df_orig$domain_id))))
  cat(sprintf('Tasks: %s\n', length(unique(df_orig$task_id))))
  cat(sprintf('Users: %s\n', length(unique(df_orig$user_id))))
  cat(sprintf('----------------------------\n'))
  
  # remove NULL answers 
  df_null_answers <- df_orig %>% filter(answer=='null')
  
  # remove time-outs
  df_timeouts <- df_orig %>% filter(timed_out)
  
  # check for empty answers and remove
  df_timeouts_no_response <- df_timeouts %>% filter(answer=='null')
  
  # missing social condition group
  df_no_condition <- df_orig %>% filter(is.na(experimental_condition))
  
  df <- df_orig %>% filter(answer != 'null') %>% filter(! is.na(experimental_condition))
  
  cat(paste0(sprintf('Responses NULL: %s', nrow(df_null_answers)), ' (', round(nrow(df_null_answers)/nrow(df_orig)*100,0), '%)\n'))
  cat(paste0(sprintf('Responses timed-out without response: %s', nrow(df_timeouts_no_response)), ' (', round(nrow(df_timeouts_no_response)/nrow(df_orig)*100,0), '%)\n'))
  cat(paste0(sprintf('Responses without an experimental condition: %s', nrow(df_no_condition)), ' (', round(nrow(df_no_condition)/nrow(df_orig)*100,0), '%)\n'))
  cat(sprintf('Total nr responses removed: %s\n', nrow(df_orig)-nrow(df)))
  cat(sprintf('Responses remaining: %s\n', nrow(df)))
  cat(sprintf('Number of users remaining: %s\n', length(unique(df$user_id))))
  cat(sprintf('----------------------------\n'))
  
  nr_hits <- df_orig %>%
    group_by(domain_name, user_id) %>%
    summarise(count = n())
  
  # users that didn't complete domains
  quitters <- df_orig %>%
    group_by(user_id, domain_id) %>%
    summarise(count = n()) %>%
    filter(count < 20)
  
  # confidence 0 is the default and means the user never indicated their confidence
  no_confidence <- df %>% filter(confidence == 0) 
  
  cat(paste0(sprintf('Responses without confidence: %s', nrow(no_confidence)), ' (', round(nrow(no_confidence)/nrow(df)*100,0), '%)\n'))
  cat(paste0(sprintf('Responses timed-out: %s', nrow(df_timeouts)), ' (', round(nrow(df_timeouts)/nrow(df)*100,0), '%)\n'))
  cat(paste0(sprintf('Incomplete hits: %s', nrow(quitters)), ' (', round(nrow(quitters)/nrow(nr_hits)*100,0), '%)\n'))
  cat(sprintf('----------------------------\n'))
  
  # re-arrange columns
  df <- df %>% 
    select(c('user_id', 'task_id', 'domain_id', 'domain_name', 'domain_description', 'prompt', 'knowledge_type', 'media_type', 'answer_type', 
             'time_limit', 'start_time', 'end_time', 'time_spent_on_question', 'timed_out', 'possible_answers', 'experimental_condition',  'cues', 
             'answer', 'correct_answer', 'is_correct', 'confidence', 'age', 'gender', 'education', 'industry', 'predicted_rank' ))
  
  return(df)
}


# -----------------------------------------------------------------------------------------------------------------------------------
# Import data
# -----------------------------------------------------------------------------------------------------------------------------------

domains <- read_csv('../data/domains.csv.zip')
tasks   <- read_csv('../data/tasks.csv.zip')
answers <- read_csv('../data/answers.csv.zip')
users   <- read_csv('../data/users.csv')
ranks   <- read_csv('../data/predicted_ranks.csv')
  

# -----------------------------------------------------------------------------------------------------------------------------------
# Combine datasets
# -----------------------------------------------------------------------------------------------------------------------------------

df_crowd <- left_join(answers, tasks, by=c('task_id'))
df_crowd <- left_join(df_crowd, domains, by=c('domain_id'))
df_crowd <- left_join(df_crowd, users, by=c('user_id'))
df_crowd <- left_join(df_crowd, ranks, by=c('domain_id', 'user_id'))  


# -----------------------------------------------------------------------------------------------------------------------------------
# Clean data and save to RData file
# -----------------------------------------------------------------------------------------------------------------------------------

df_crowd <- df_crowd %>%
  mutate(is_correct = ifelse(answer_type=='open-ended', NA, 
                             ifelse(answer_type == "discrete" & answer == correct_answer, TRUE, FALSE)),
         start_time = as.POSIXct(start_time, format=c('%Y-%m-%d %H:%M:%S')),
         end_time = as.POSIXct(end_time, format=c('%Y-%m-%d %H:%M:%S')),
         time_spent_on_question = unclass(difftime(end_time, start_time, units='secs')),
         timed_out = ifelse(time_spent_on_question > time_limit, TRUE, FALSE))

crowd <- clean_data(df_crowd)

save(crowd, file='../data/crowd.RData')



