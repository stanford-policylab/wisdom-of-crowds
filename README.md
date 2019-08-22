# wisdom-of-crowds
Studying the "Wisdom of Crowds" at Scale

General Usage Notes
-------------------

The data and scripts included in this repo were used to produce results in the paper, Studying the “Wisdom of Crowds” at Scale, by Camelia Simoiu, Chiraag Sumanth, Alok Mysore, and Sharad Goel.
 
More details regarding methodology can be found in the paper: https://5harad.com/papers/wisdom-of-crowds.pdf


Background
-------------------

![Hive](https://dzpz27bktbdd8.cloudfront.net/img/research.gif)

At a 1906 county fair, the statistician Francis Galton watched as eight hundred people competed to guess the weight of an ox. He famously observed that the median of the guesses, 1,207 pounds, was, remarkably, within 1% of the true weight. 

Simple aggregation -- as in the case of Galton's ox competition, or voting in democratic elections -- has been shown to be a surprisingly powerful technique for prediction, inference, and decision-making. Over the last century, there have been dozens of studies that examine this wisdom of crowds effect. However, given the diversity of experimental designs, subject pools, and aggregation methods used, it has proven difficult to compare results and extract general principles. It is thus unclear whether these documented examples are a representative collection of a much larger space of tasks that exhibit a wisdom of crowds phenomenon, or conversely, whether they are highly specific instances of an interesting, though ultimately limited occurrence. 

We further tested the effect of different types of social influence on crowd performance. Participants were randomly assigned to one of four different conditions in which they saw varying degrees of information on the responses of others: "consenus", "most recent", "most confident", and a control condition where respondents received no social information. The "most recent" condition displayed the previous three responses to the question. The "consensus" condition displayed the three most frequently selected responses in order from highest to lowest if the question was categorical, and the median answer up to that point if the question was open-ended. Finally, the "most confident" condition displayed the previous three responses with the highest self-reported confidence. 

We developed an online game to systematically investigate the wisdom of crowds effect. Players are presented with 1,000 questions drawn from 50 domains. The questions include tests of explicit knowledge (e.g., general knowledge, spatial reasoning, and popular culture), tacit knowledge (e.g., emotional intelligence, knowledge of cultural norms, and foreign language skills), and prediction ability (e.g., election outcomes, and box office success of upcoming movies). The domains span four different types of media (text, image, video, and audio) and four answer types (point estimate, binary, multiple choice, and ranking). 

The scale of this experiment allowed us to analyze a much larger and more diverse set of tasks than would be possible with traditional methods. In total, we collected more than 500,000 responses from nearly 2,000 participants. We hope that our work provides firmer footing for future researchers to continue investigating the wisdom of crowds phenomenon. 


Data
-------------------

The data files can be downloaded from `data/original/`.

**answers.csv.zip** 
 - `task_id`: Unique identifier for the question
 - `user_id`: Unique identifier for the respondent
 - `answer`: The respondent's answer; a NULL value indicates no answer was provided
 - `confidence`: The respondent's self-reported confidence level as an integer from 0 to 5, where 0 is the default and means that the respondent never selected a confidence level, 1 is the lowest confidence level possible, and 5 is the highest confident level possible
 - `start_time`: Timestamp indicating when the repspondent began the question (i.e., when the question first loaded) 
 - `end_time`: Timestamp when the respondent finished responding to the question (i.e., when the respondent clicked "Next" to move on to the next question)
 - `cues`: The social cues seen by the respondent on the question, where "Not enough data" means there were insufficient answers in the database to display to the respondent (i.e., less than 3 responses), and "NA" means the field is not applicable (i.e., in the case of the control condition, where no social cues were displayed)

**domains.csv.zip**
  - `domain_id`: Unique identifier for the domain
  - `domain_name`: Short name for the domain
  - `domain_description`: The description shown to participants at the beginning of each domain
  - `knowledge_type`: One of "tacit"", "spatial reasoning"", "knowledge"", "pop culture", "prediction"
  - `media_type`: One of "video" "image", "audio", "none" 
  - `answer_type`: One of "discrete", "open-ended" 
  - `time_limit`: Time limit for each question in the domain in seconds

**tasks.csv.zip**
  - `task_id`: ID associated with the question
  - `domain_id`: ID associated with the domain
  - `prompt`: The instruction prompt shown to the respondent for each question
  - `possible_answers`: A comma-separated string listing the allowed answer choices available to respondents (only relevant for discrete questions)
  - `correct_answer`: The correct answer to the question
  - `path_to_media`: The path to the corresponding media file shown to respondents for each question (e.g., image, video), if applicable

**users.csv.zip**
  - `user_id`: Unique identifier for the respondent
  - `age`: The self-reported age of the respondent
  - `gender`: The self-reported gender of the respondent, one of "M" (male), or "F" (female)
  - `education`: The self-reported highest level of education attained of the respondent
  - `industry`: The self-reported industry of employment of the respondent
  - `experimental_condition`: The experimental condition the respondent was assigned to (one of: "Control", "Most recent", "Consensus", "Most confident")

**predicted_ranks.csv.zip**
  - `user_id`: Unique identifier for the respondent
  - `domain_id`: Unique identifier for the domain
  - `predicted_rank`: After being shown a description of the domain, respondents were asked to guess their rank in the domain (how well they would perform relative to others); their response is stored as an integer from 1-100
  



Generating a clean dataset
-----------------------------------------

**data_processing.R**
  - Processes and combines responses, saving a clean dataset as an RData object
  - Requirements: Data files in `data/original/` (5 files)
  - Libraries: `base`, `dplyr`, `readr`
  - Output: saves `crowd.RData` in `data/`
  
  
Media files
-----------------------------------------

Some domains included additional media files (e.g., a video, image) that were shown to respondents. The path to the file for each question can be found in `data/original/tasks.csv.zip` (see `path_to_media` field), and all media files can be found in the `domains/` folder.


Additional notes
-----------------------------------------
  - Domain 101, task 10752 has no correct answer, as this movie was not released in 2017 as planned.



