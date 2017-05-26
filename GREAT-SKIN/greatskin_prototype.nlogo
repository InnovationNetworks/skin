;SKIN
;====
;
;Simulating Knowledge Dynamics in Innovation Networks
;
;SKIN is a multi-agent model of innovation networks in knowledge-intensive industries grounded in empirical research and theoretical frameworks from innovation economics and economic sociology. The agents represent innovative firms who try to sell their innovations to other agents and end users but who also have to buy raw materials or more sophisticated inputs from other agents (or material suppliers) in order to produce their outputs. This basic model of a market is extended with a representation of the knowledge dynamics in and between the firms. Each firm tries to improve its innovation performance and its sales by improving its knowledge base through adaptation to user needs, incremental or radical learning, and co-operation and networking with other agents.
;
;CREDITS
;-------
;
;To cite the SKIN model please use the following acknowledgement:
;
;Gilbert, Nigel, Ahrweiler, Petra and Pyka, Andreas (2010) The SKIN (Simulating Knowledge Dynamics in Innovation Networks) model.  University of Surrey, Johannes Gutenberg University Mainz and University of Hohenheim.
;
;Copyright 2003 - 2017 Michel Schilperoord, Nigel Gilbert, Petra Ahrweiler and Andreas Pyka. All rights reserved.
;
;Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed: a) this copyright notice is included. b) this model will not be redistributed for profit without permission and c) the requirements of the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License <http://creativecommons.org/licenses/by-nc-sa/3.0/> are complied with.
;
;The authors gratefully acknowledge funding during the course of development of the model from the European Commission, DAAD, and the British Council.
;
;
;
; This code is the prototype version of the GREAT-SKIN model, an adaptation of the INFSO-SKIN model to the study scope of
;    "Governance for Responsible Innovation" - EU FP7
;
; version 2.0   25 August    2003
; version .1    1  September 2003   Bugs caused by extreme parameter values removed.
;                                   Partnerships added
; version .2    17 September 2003   Networks added
; version .3    26 October   2003   Some network bugs removed and plots added
; version .4    1  November  2003   Economy added
; version .5    8  November  2003   Bugs, converted to NetLogo 2.0
; version .7    12 November  2003   Partners cannot be from networks
; version .9    13 November  2003   (Hamburg) Network bugs removed
; version 3.0   14 November  2003   Tidy up; make environmental inputs and outputs product ranges
; version .2    27 December  2003   Changed incremental research direction setting
; version .3    27 December  2003   Network graphics
; version .6    2  January   2004   Herfindahl index, bug fixes, shorter partner search
; version .7    15 February  2004   Connectivity graph; variable start-ups; random initial capital;
;                                   increased radical research threshold; changed network display
; version .8    24 January   2006   Added degree distribution plot
; version .9    31 May       2006   Added code for Behaviour Space runs
; version 4.0   16 June      2006   Real valued abilities, many bug fixes
; version 4.22  16 August    2006   IH no longer dependent on Abilities
;                                   Networks now cost partners to create
; version 4.23  19 August    2006   Stop crashing in make-networks
; version 4.24  19 August    2006   reward-to-trigger-start-up adjusted to 950
; version 4.27  5  September 2006   Increase final-price; changed back to map-artefact; using cost-plus pricing;
;                                   incr-step now proportional to capability value
; version 5     23 April     2010   Stripped down and simplified version of v4.29, converted to NetLogo 4.1
; infso            August    2011   Adaptation of version 5 for DG INFSO study scope
; great            June      2015   Adaptation of INFSO for GREAT study scope


extensions [array table sql pathdir]

globals [
  Simdb-location                  ; location of the simulation database (../greatsim)
  ; Model-version                 ; version of this model
  ; Experiment-name               ; name of the current experiment (set in BehaviorSpace)

  ;;; Parameters with sliders and presets.

  ; Participants-settings         ; <P> = RES, DFI, SME or CSO
  ; nParticipants                 ; number of participants
  ; Percent-<P>                   ; percentage of Type<P> participants
  ; Size-<P>                      ; size (kene length) of Type<P> participants
  ; Cutoff-point                  ; number of calls used to make the starting network

  ; Instruments-settings          ; <I> = CIP
  ; Size-<I>                      ; desired size (number of partners) of Type<I> projects
  ; Size-min-<I>                  ; smallest size of Type<I> projects (0 if not limited)
  ; Size-max-<I>                  ; largest size of Type<I> projects (999 if not limited)
  ; <P>-min-<I>                   ; lowest number of Type<P> partners in Type<I> projects (0 if not limited)
  ; <P>-max-<I>                   ; highest number of Type<P> partners in Type<I> projects (0 if not possible, 999 if not limited)
  ; Duration-<I>                  ; duration (number of months) of Type<I> projects
  ; Contribution-<I>              ; EC contribution (per month and partner) for Type<I> projects
  ; Match-<I>                     ; number of capabilities in the call's range which must appear in an eligible Type<I> proposal
  ; RRI-criteria-<I>              ; the use of RRI scores as evaluation criteria for Type<I> proposals/projects
  ; SCI-min-<I>                   ; the required SCI score
  ; RRI-min-<I>                   ; the required RRI score
  ; RRI-balance-<I>               ; the balance of RRI/SCI scores (e.g. 50/50)

  ; Call-settings                 ; <C> = Call1 ... Call6
  ; Deadline-Call<C>              ; deadline (month) of Call<C>
  ; Funding-Call<C>               ; funding available for Call<C>
  ; Themes-Call<C>                ; thematic orientation (number of themes) of Call<C>
  ; Orientation-Call<C>           ; research orientation (0 basic .. 9 applied) of Call<C>
  ; Range-Call<C>                 ; number of capabilities (range) which are desired for Call<C> proposals
  ; Repeat-last-call?             ; repeat the last call 6 times?

  ;;; Other parameters with presets but without sliders.

  ; Themes-settings
  nCapabilities                   ; global number of capabilities possible
  nThemes                         ; global number of themes possible
  sector-capabilities-per-theme   ; number of 'sector' capabilities (per theme) given to all agents
  common-capabilities-per-theme   ; number of 'common' capabilities (per theme) given to all agents
  rare-capabilities-per-theme     ; number of 'rare' capabilities (per theme) given exclusively to SMEs
  special-capabilities-per-theme  ; number of 'special' capabilities (per theme) given exclusively to CSOs
  special-cap-list                ; list of all special capabilities

  ; Other-settings
  funding                         ; total funding for all 6 calls
  project-cap-ratio               ; "room" (number of capabilities) needed for adding a project (or proposal)
  search-depth                    ; search depth for finding partners
  invite-previous-partners-first? ; search partners first in previous partners network
  time-before-call-deadline       ; months between a call's publication date and deadline
  time-before-project-start       ; months between a call's deadline and start of the projects
  time-between-deliverables       ; months between a sub-project's output of deliverables
  max-deliverable-length          ; maximum number of capabilities used for making a deliverable
  adjust-expertise-rate           ; global likelihood of adjusting expertise levels
  sub-nr-max                      ; highest amount of sub-projects (999 if not limited)
  sub-size-min                    ; smallest size of sub-projects (0 if not limited)

  ; some other globals (not parameters)
  log?                            ; switch off for more speed
  super?                          ; aggregation on/off
  compute-network-distances?      ; computationally expensive!
  highest-proposal-nr             ; for setting proposal-nr
  the-current-call                ; for monitoring the latest call
  partnerships-matrix             ; matrix with history of partnerships used for weighted graph
  partnerships-matrix-Super
  nodes-att-values                ; arrays used for dynamic graph
  edges-att-values

  ; Dictionaries for getting and setting the values of an instrument, call or theme.
  ; Example: for getting the duration of CIP projects use [instr-duration] of table:get instruments-dict "CIP"
  ; This is useful when the instrument, call or theme of interest is not known prior to running the model.
  instruments-dict
  calls-dict
  themes-dict
  participants-dict

  ;;; measures that are updated while the model is running

  ; some measures for proposals which are updated when proposals are dissolved
  proposals-count                 ; number of (submitted) proposals
  proposals-with-SME-count        ; number of (submitted) proposals with at least one SME in consortium
  proposals-with-CSO-count
  proposals-type                  ; list for storing the type of proposals
  proposals-call                  ; list for storing the call of proposals
  proposals-size                  ; list for storing the size (number of partners) of proposals
  proposals-RES  proposals-DFI  proposals-SME  proposals-CSO  ; lists for storing the number of Type<P> participants in proposals
  proposals-anticipation          ; lists for storing the RRI/SCI scores of proposals
  proposals-participation
  proposals-reflexivity
  ; no responsiveness score for proposals
  proposals-capability-match
  proposals-expertise-level
  proposals-RRI
  proposals-SCI
  ;;;
  proposals-size-Super
  proposals-RES-Super  proposals-DFI-Super  proposals-SME-Super  proposals-CSO-Super

  ; some measures for projects which are updated when projects are dissolved
  projects-count                  ; number of (completed) projects
  projects-with-SME-count         ; number of (completed) projects with at least one SME in consortium
  projects-with-CSO-count
  projects-type                   ; list for storing the type of projects
  projects-call                   ; list for storing the call of projects
  projects-size                   ; list for storing the size (number of partners) of projects
  projects-duration               ; list for storing the duration (number of months) of projects
  projects-contribution           ; list for storing the EC contribution for projects
  projects-RES  projects-DFI  projects-SME  projects-CSO  ; lists for storing the number of Type<P> participants in projects
  projects-anticipation           ; lists for storing the RRI/SCI scores of projects
  projects-participation
  projects-reflexivity
  projects-responsiveness
  projects-capability-match
  projects-expertise-level
  projects-RRI
  projects-SCI
  ;;;
  projects-size-Super
  projects-RES-Super  projects-DFI-Super  projects-SME-Super  projects-CSO-Super

  ; Some network measures which are updated according to a user-specified interval "Update-Network-Measures-interval" (1 = each tick to
  ; 112 = end of run only) The computations can slow things down considerably especially with large networks, so in many cases one would
  ; prefer to set the interval to 112.
  which-network
  participants-in-net
  count-of-edges
  count-of-possible-edges
  density
  number-of-components
  component-size
  largest-component-size
  largest-start-node
  average-degree
  connected?
  num-connected-pairs
  diameter
  average-path-length
  clustering-coefficient
  infinity

  ; Some measures for knowledge and project outputs which are updated each tick.
  capabilities-RES               ; lists for storing the presence of capabilities (e.g. how many participants of Type<P> have capability x?)
  capabilities-DFI
  capabilities-SME
  capabilities-CSO
  capabilities-frequency-RES     ; lists for storing the frequency of capabilities in the capabilities-<P> lists
  capabilities-frequency-DFI
  capabilities-frequency-SME
  capabilities-frequency-CSO
  capabilities-diffusion         ; share of participants carrying a capability from a certain theme
  kenes-length-RES               ; lists for storing the length of the kenes of Type<P> participants
  kenes-length-DFI
  kenes-length-SME
  kenes-length-CSO
  knowledge                      ; the sum of all kene lengths of participants
  knowledge-flow                 ; the sum of all knowledge flow within sub-projects, which is measured in the "learn-from-partners" procedure
  kf-RES-to-RES  kf-DFI-to-RES  kf-SME-to-RES  kf-CSO-to-RES
  kf-RES-to-DFI  kf-DFI-to-DFI  kf-SME-to-DFI  kf-CSO-to-DFI
  kf-RES-to-SME  kf-DFI-to-SME  kf-SME-to-SME  kf-CSO-to-SME
  kf-RES-to-CSO  kf-DFI-to-CSO  kf-SME-to-CSO  kf-CSO-to-CSO
  patents                        ; the number of patents (deliverables of projects)
  articles                       ; the number of journal articles (deliverables of projects)
  ;;;
  capabilities-RES-Super
  capabilities-DFI-Super
  capabilities-SME-Super
  capabilities-CSO-Super
  capabilities-frequency-RES-Super
  capabilities-frequency-DFI-Super
  capabilities-frequency-SME-Super
  capabilities-frequency-CSO-Super
  capabilities-diffusion-Super
  kenes-length-RES-Super
  kenes-length-DFI-Super
  kenes-length-SME-Super
  kenes-length-CSO-Super

  ; Some lists for storing and exporting run data. This could be automatically done in BehaviorSpace, but since we need more options
  ; for exporting data to the Viewer there is a "export-" procedure written for this task.
  run-data-participants-RES
  run-data-participants-RES-net
  run-data-participants-DFI
  run-data-participants-DFI-net
  run-data-participants-SME
  run-data-participants-SME-net
  run-data-participants-CSO
  run-data-participants-CSO-net
  run-data-proposals-submitted
  run-data-proposals
  run-data-proposals-with-SME
  run-data-proposals-with-CSO
  run-data-proposals-small
  run-data-proposals-big
  run-data-projects
  run-data-projects-started
  run-data-projects-with-SME
  run-data-projects-with-CSO
  run-data-projects-small
  run-data-projects-big
  run-data-network-density
  run-data-network-components
  run-data-network-largest-component
  run-data-network-avg-degree
  run-data-network-avg-path-length
  run-data-network-clustering
  run-data-knowledge
  run-data-knowledge-flow
  run-data-kf-RES-to-RES  run-data-kf-DFI-to-RES  run-data-kf-SME-to-RES  run-data-kf-CSO-to-RES
  run-data-kf-RES-to-DFI  run-data-kf-DFI-to-DFI  run-data-kf-SME-to-DFI  run-data-kf-CSO-to-DFI
  run-data-kf-RES-to-SME  run-data-kf-DFI-to-SME  run-data-kf-SME-to-SME  run-data-kf-CSO-to-SME
  run-data-kf-RES-to-CSO  run-data-kf-DFI-to-CSO  run-data-kf-SME-to-CSO  run-data-kf-CSO-to-CSO
  run-data-knowledge-patents
  run-data-knowledge-articles
  run-data-capabilities
  run-data-capabilities-diffusion
  ;;;
  run-data-participants-RES-Super
  run-data-participants-RES-net-Super
  run-data-participants-DFI-Super
  run-data-participants-DFI-net-Super
  run-data-participants-SME-Super
  run-data-participants-SME-net-Super
  run-data-participants-CSO-Super
  run-data-participants-CSO-net-Super
  run-data-proposals-small-Super
  run-data-proposals-big-Super
  run-data-projects-small-Super
  run-data-projects-big-Super
  run-data-capabilities-Super
  run-data-capabilities-diffusion-Super
]


; the eight themes, which DG INFSO has defined
breed [themes theme]

; the instruments: the five CIP-ICT-PSP programmes
breed [instruments instrument]

; the calls of the Commission: CIP-ICT-PSP-YYYY-N
breed [calls call]

; three different populations: research institutes (including universities), diversified firms, SMEs and CSOs
breed [participants participant]

; the research proposals with their consortia
breed [proposals proposal]

; the research projects with their results
breed [projects project]

; the research sub-projects working on a specific deliverable
breed [subprojects subproject]


themes-own [
  theme-nr
  theme-description
]

instruments-own [
  instr-nr
  instr-type                      ; = "CIP"
  instr-size                      ; desired size (number of partners)
  instr-size-min                  ; smallest size
  instr-size-max                  ; largest size
  instr-sub-nr-max                ; highest amount of sub-projects
  instr-sub-size-min              ; smallest size of sub-projects
  instr-RES-min                   ; min number of partners of type RES
  ;instr-RES-max                  ; max number of partners of type RES
  instr-DFI-min                   ; min number of partners of type DFI
  ;instr-DFI-max                  ; max number of partners of type DFI
  instr-SME-min                   ; min number of partners of type SME
  ;instr-SME-max                  ; max number of partners of type SME
  instr-CSO-min                   ; min number of partners of type CSO
  ;instr-CSO-max                  ; max number of partners of type CSO
  instr-duration-avg              ; the length of the project (in months)
  instr-duration-stdev
  instr-contribution              ; the Commission's contribution (multiply by size and duration)
  instr-match                     ; the required capability match
  instr-RRI-criteria              ; the use of RRI scores as evaluation criteria
  instr-SCI-min                   ; the required SCI score
  instr-RRI-min                   ; the required RRI score
  instr-RRI-balance               ; the balance of RRI/SCI scores (e.g. 50/50)
]

calls-own [
  call-nr
  call-type                       ; ~ instrument type
  call-id                         ; for the empirical case (e.g. "CIP-ICT-PSP-YYYY-N")
  call-publication-date           ; the publication date of the Call
  call-deadline                   ; the deadline of the Call
  call-funding                    ; funding available for projects (percentage of total funding)
  call-themes                     ; thematic orientation of the Call
  call-orientation                ; the desired research orientation (0 basic .. 9 applied)
  call-special-caps?              ; include special capabilities?
  call-range                      ; the Call's range (number of capabilities)
  call-status                     ; = "open" or "closed"
  call-evaluated?                 ; has the Call been evaluated?
  call-counter                    ; table for counting proposals having a given status
                                  ; e.g. table:get call-counter "initiated" -> number of initiated proposals
  ; kene
  call-capabilities               ; a range of capabilities (at least one of which must appear in an eligible proposal)
]

participants-own [
  my-nr
  my-snr                          ; for "super"-participants like FRAUNHOFER
  my-type                         ; = "res", "dfi", "sme" or "cso"
  my-id                           ; for the empirical case (e.g. "100364091")
  my-name                         ; for the empirical case (e.g. "IBM ISRAEL")
  my-proposals                    ; the proposals I am currently in
  my-projects                     ; the projects I am currently in
  my-partners                     ; agentset of my current partners
  my-previous-partners            ; agentset of agents with which I have previously partnered
  my-cap-capacity                 ; the length of the kene, which is defined by the type of the participant
                                  ; but cannot be less than 5 quadruples (the capacity for SMEs)
  ; kene
  my-capabilities                 ; the kene of the participant, part 1
  my-abilities                    ; the kene of the participant, part 2
  my-expertises                   ; the kene of the participant, part 3
  my-orientations                 ; the kene of the participant, part 4

  ; Some lists used for computing participation measures
  participation-in-proposals
  participation-in-projects

  ; Some variables used for computing network measures
  explored?
  distance-from-other-participants
  node-clustering-coefficient
]

proposals-own [
  proposal-nr
  proposal-type                   ; ~ instrument type
  proposal-call                   ; the call
  proposal-consortium             ; the consortium partners
  proposal-coordinator            ; coordinator of the proposal
  proposal-status                 ; = 0 ("initiated") .. 7 ("dissolved")
  proposal-ranking-nr             ; set by the Commission

  ; scores
  anticipation-score
  participation-score
  reflexivity-score
  capability-match-score
  expertise-level-score
  RRI-score
  SCI-score

  ; kene
  proposal-capabilities           ; compilation of kene quadruples of the consortium, part 1
  proposal-abilities              ; compilation of kene quadruples of the consortium, part 2
  proposal-expertises             ; compilation of kene quadruples of the consortium, part 3
  proposal-orientations           ; compilation of kene quadruples of the consortium, part 4
  proposal-contributors           ; who added the kene quadruples?
]

projects-own [
  project-nr                      ; = proposal-nr
  project-type                    ; = proposal-type
  project-call                    ; = proposal-call
  project-consortium              ; = proposal-consortium
  project-acronym                 ; for the empirical case (e.g. "+SPACES")
  project-start-date              ; starting date of the project (start of the research)
  project-end-date                ; when the project is completed
  project-contribution            ; funding by the Commission
  project-status                  ; = 8 ("started") .. 10 ("dissolved")
  project-subprojects             ; the sub-projects in which research is concentrated
  project-successful?             ; success depends on the outputs of the subprojects
  project-kf                      ; total knowledge flow during the project
  project-kf-CSO                  ; total knowledge flow during the project involving CSOs

  ; scores
  anticipation-score
  participation-score
  reflexivity-score
  responsiveness-score
  capability-match-score
  expertise-level-score
  RRI-score
  SCI-score

  ; kene
  project-capabilities            ; = proposal-capabilities
  project-abilities               ; = proposal-abilities
  project-expertises              ; = proposal-expertises
  project-orientations            ; = proposal-orientations
  project-contributors            ; = proposal-contributors
]

subprojects-own [
  subproject-nr
  subproject-project              ; the "super"-project
  subproject-deliverable          ; the current sub-project deliverable (~ innovation hypothesis)
  subproject-partners             ; the partners allocated to the sub-project
  subproject-status               ; = 8 ("started") .. 10 ("dissolved")
  subproject-outputs              ; the (published) deliverables of the sub-project
  incr-research-direction         ; direction of changing an ability (for incremental research)
  ability-to-research             ; the ability that is being changed by incremental research

  ; kene
  subproject-capabilities         ; subset of kene quadruples of the project, part 1
  subproject-abilities            ; subset of kene quadruples of the project, part 2
  subproject-expertises           ; subset of kene quadruples of the project, part 3
  subproject-orientations         ; subset of kene quadruples of the project, part 4
  subproject-contributors         ; who added the kene quadruples?
]


; Instrument types:
;   CIP - Competitiveness and Innovation Framework Programme

; Participant types:
;   RES - research institutes (including universities)
;   DFI - diversified firms
;   SME - SMEs
;   CSO - civil society organizations

; Capabilities:
; We structure the knowledge space (e.g. 1000 different capabilities by allocating e.g. 100 capabilities to each of
; the CIP-ICT-PSP themes. In order to allow the SMEs to play their special role we define 10 capabilities per theme
; as 'rare' capabilities and give these capabilities in the starting distribution exclusively to SMEs. We define 10
; capabilities per theme as 'special' capabilities and give these capabilities exclusively to CSOs.

; Stages:
;   1 - Agents develop proposals
;   2 - Proposals are evaluated
;   3 - Consortia carry out projects
;   4 - Projects are evaluated

; Status:                      Next status:                            Go into stage:
;   0 - Proposal initiated       to 2, if enough partners                1 - Writing the proposal (inviting partners)
;   1 - Proposal stopped         not enough partners
;   2 - Proposal submitted       to 3 or 4, depending on evaluation      2 - Evaluation of proposal (eligibility)
;   3 - Proposal eligible        to 3 or 4, depending on evaluation      2 - Evaluation of proposal (ranking)
;   4 - Proposal ineligible
;   5 - Proposal accepted        to 7
;   6 - Proposal rejected        to 7
;   7 - Proposal dissolved       to 8, if proposal is accepted
;   8 - Project started          to 9, after duration of project         3 - Creating the deliverables
;   9 - Project completed        to 10, after evaluation                 4 - Evaluation of project
;  10 - Project evaluated        to 11
;  11 - Project dissolved        stop. project successful?

; RRI-scores:
;   anticipation-score      : any special capabilities?
;   participation-score     : any CSO(s) in the consortium?
;   reflexivity-score       : diversity of capabilities
;   responsiveness-score    : any strategy changes?

; SCI-scores:
;   capability-match        : match of capabilities
;   expertise-level         : mean expertise level


;;; SETUP
;;;
;;;


to setup
  no-display
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks

  ifelse behaviorspace-run-number > 0
    [ setup-simdb (behaviorspace-run-number = 1) ]
    [ setup-workdir ]
  if not Empirical-case? [ setup-presets ]
  setup-globals

  ; create a population of participants (research institutes, diversified firms and SMEs),
  ; a number of themes, the instruments and a series of calls (to be published later)

  ifelse Empirical-case? [
    load-empirical-case 6
  ] [
    if Cutoff-point > 0 [ load-empirical-case Cutoff-point ]
    initialise-themes
    initialise-participants
    initialise-instruments
    initialise-calls
    ask participants [ make-kene ]
    ask calls [ make-cap-range ]
  ]

  ; create a starting network based on the first calls before the cutoff point
  if Cutoff-point > 0 [
    make-starting-network
    if not Empirical-case? [
      ; delete all loaded projects if in simulation mode - we don't need them no longer
      ask projects [ die ]
    ]
  ]

  ; initialise history of partnerships
  let n count participants
  set partnerships-matrix array:from-list n-values (n * n) [0]
  set partnerships-matrix-Super array:from-list n-values (n * n) [0]

  ;update-network-measures
  if not Empirical-case?
    [ update-knowledge-measures ]
  update-the-plots
  update-run-data

  export-network-data (behaviorspace-run-number > 0)
  if not Empirical-case?
    [ export-knowledge-data (behaviorspace-run-number > 0) ]
end


to setup-simdb [delete-old-experiment-data?]
  let sep pathdir:get-separator
  set Simdb-location (word pathdir:get-home sep "greatskin") ; /Users/<user name>/greatskin
  set Model-version "1.0 (06.2015)"
  ; if this is a new model version then create its directory
  let model-dir (word Simdb-location sep "greatskin" Model-version)
  let list-of-model-versions pathdir:list (word Simdb-location)
  if not member? (word "greatskin" Model-version) list-of-model-versions
    [ pathdir:create model-dir ]
  ; if this is a new experiment then create its directory and sub-directories
  let experiment-dir (word Simdb-location sep "greatskin" Model-version sep Experiment-name)
  let list-of-experiments pathdir:list (word Simdb-location sep "greatskin" Model-version)
  ifelse member? Experiment-name list-of-experiments [
    if delete-old-experiment-data? [
      ; empty the entire contents of the data and report sub-directories
      let rundata-dir (word experiment-dir sep "data" sep "rundata")
      let list-of-rundata pathdir:list rundata-dir
      foreach list-of-rundata [ file-delete (word rundata-dir sep ?) ]
      let netdata-dir (word experiment-dir sep "data" sep "netdata")
      let list-of-netdata-gml pathdir:list (word netdata-dir sep "gml")
      foreach list-of-netdata-gml [ file-delete (word netdata-dir sep "gml" sep ?) ]
      let list-of-netdata-gexf pathdir:list (word netdata-dir sep "gexf")
      foreach list-of-netdata-gexf [ if not (? = "dyn") [ file-delete (word netdata-dir sep "gexf" sep ?) ] ]
      let list-of-netdata-dyn-gexf pathdir:list (word netdata-dir sep "gexf" sep "dyn")
      foreach list-of-netdata-dyn-gexf [ file-delete (word netdata-dir sep "gexf" sep "dyn" sep ?) ]
      let kdata-dir (word experiment-dir sep "data" sep "kdata")
      let list-of-kdata pathdir:list kdata-dir
      foreach list-of-kdata [ file-delete (word kdata-dir sep ?) ]
      let charts-dir (word experiment-dir sep "report" sep "charts")
      let list-of-charts pathdir:list charts-dir
      foreach list-of-charts [ file-delete (word charts-dir sep ?) ]
      let graphs-dir (word experiment-dir sep "report" sep "graphs")
      let list-of-graphs pathdir:list graphs-dir
      foreach list-of-graphs [ file-delete (word graphs-dir sep ?) ]
      let tables-dir (word experiment-dir sep "report" sep "tables")
      let list-of-tables pathdir:list tables-dir
      foreach list-of-tables [ file-delete (word tables-dir sep ?) ]
    ]
  ] [
    pathdir:create experiment-dir
    pathdir:create (word experiment-dir sep "data" sep "rundata")
    pathdir:create (word experiment-dir sep "data" sep "netdata")
    pathdir:create (word experiment-dir sep "data" sep "netdata" sep "gml")
    pathdir:create (word experiment-dir sep "data" sep "netdata" sep "gexf")
    pathdir:create (word experiment-dir sep "data" sep "netdata" sep "gexf" sep "dyn")
    pathdir:create (word experiment-dir sep "data" sep "kdata")
    pathdir:create (word experiment-dir sep "report" sep "tables")
    pathdir:create (word experiment-dir sep "report" sep "charts")
    pathdir:create (word experiment-dir sep "report" sep "graphs")
  ]
end


to setup-workdir
  let sep pathdir:get-separator
  ; create the work directory structure if it does not exist yet, otherwise
  ; empty the entire contents of the data sub-directories
  let list-of-contents pathdir:list ""
  ifelse member? "work" list-of-contents [
    let rundata-dir (word "work" sep "rundata")
    let list-of-rundata pathdir:list rundata-dir
    foreach list-of-rundata [ file-delete (word rundata-dir sep ?) ]
    let netdata-dir (word "work" sep "netdata")
    let list-of-netdata-gml pathdir:list (word netdata-dir sep "gml")
    foreach list-of-netdata-gml [ file-delete (word netdata-dir sep "gml" sep ?) ]
    let list-of-netdata-gexf pathdir:list (word netdata-dir sep "gexf")
    foreach list-of-netdata-gexf [ if not (? = "dyn") [ file-delete (word netdata-dir sep "gexf" sep ?) ] ]
    let list-of-netdata-dyn-gexf pathdir:list (word netdata-dir sep "gexf" sep "dyn")
    foreach list-of-netdata-dyn-gexf [ file-delete (word netdata-dir sep "gexf" sep "dyn" sep ?) ]
    let kdata-dir (word "work" sep "kdata")
    let list-of-kdata pathdir:list kdata-dir
    foreach list-of-kdata [ file-delete (word kdata-dir sep ?) ]
  ] [
    pathdir:create "work"
    pathdir:create (word "work" sep "rundata")
    pathdir:create (word "work" sep "netdata")
    pathdir:create (word "work" sep "netdata" sep "gml")
    pathdir:create (word "work" sep "netdata" sep "gexf")
    pathdir:create (word "work" sep "netdata" sep "gexf" sep "dyn")
    pathdir:create (word "work" sep "kdata")
  ]
end


; Set parameters to pre-defined settings (presets).
; The purpose of presets is to make it easier to design experiments.
; When presets are selected using the choosers in the interface or in BehaviorSpace, groups of parameters will be set at once.
; For example, by using the Participants-settings preset the group of parameters for participants can be set.
; It is however not obligatory to use presets. When "no preset" is selected for certain groups of parameters, setup will
; skip the preset procedure for these parameter groups and not change the sliders for these groups.
; It is thus possible to fix with presets values for a certain groups of parameters, while experimenting with different parameter
; values for the remaining parameter groups, using sliders or [parameter values] lists in BehaviorSpace.

to setup-presets
  let i 0
  set i position Participants-settings ["no preset" "Small (no CSOs)" "Small with CSOs"]
  if i > 0 [
    ; CIP data cannot be used to estimate the Baseline parameter settings since there is no field on participant type.
    ; However the GREAT survey includes questions where participant type is included in the response.

    ; The total number of project partners according to the dataset is 2474
    ; In simulations, the Baseline population will need to be larger than the list of participants in the database.
    ; This is to account for the fact that some actors that did participate may not be in that list, simply because of the
    ; circumstance that they were not part of any successful proposal.
    ; For this reason, the Baseline number of participants could be, realistically, anywhere between 3500 and 5000.
    ; The model's sensitivity to this number can be looked at while doing a parameter sweep over this range.

    ; An important detail with regard to the number of participants is the number of CSOs.
    ; Again, we need a realistic range for parameter sweeping.

    ;             Baseline (no CSOs)            with CSOs
    ;             ------------------        ------------------
    ;             Count      Percent        Count      Percent
    ;   RES        1050         30.0         1050         27.3
    ;   DFI        1050         30.0         1050         27.3
    ;   SME        1400         40.0         1400         36.4
    ;   CSO           0          0.0          350          9.0
    ;
    ;   TOTAL      3500        100.0         3850        100.0

    ; For prototype development a small population is used, mainly for the reason of speed.

    ;              small (no CSOs)           small with CSOs
    ;             ------------------        ------------------
    ;             Count      Percent        Count      Percent
    ;   RES          30         30.0           30         27.3
    ;   DFI          30         30.0           30         27.3
    ;   SME          40         40.0           40         36.4
    ;   CSO           0          0.0           10          9.0
    ;
    ;   TOTAL       100        100.0          110        100.0

    ; The size of CSOs is equal to the size of SMEs

    set i i - 1
    set Cutoff-point 0

    set nParticipants item i [100 110]
    set Perc-RES item i [30.0 27.3]  set Perc-DFI item i [30.0 27.3]
    set Perc-SME item i [40.0 36.4]  set Perc-CSO item i [0.0 9.0]
    set Size-RES 25  set Size-DFI 15  set Size-SME 10  set Size-CSO 10
  ]
  set i position Instruments-settings ["no preset" "Baseline (0% RRI)" "Balanced (50% RRI)"]
  if i > 0 [
    set i i - 1
    ; CIP data is used to estimate the Baseline parameter settings

    ; The CIP data describes 5 instruments, all ICT Policy Support Programme (CIP-ICT-PSP)
    ;
    ;                              Nr of Projects      Cost (EUR)      EU Contribution     EU Share
    ;                              --------------    -------------     ---------------     --------
    ; Pilot Type A (PA)                  13           202.430.000         99.810.000         49.3
    ; Pilot Type B (PB)                 136           625.550.000        308.280.000         49.3
    ; Thematic Network (TN)              40            31.090.000         31.020.000         99.8
    ; Pilot actions (P)                   2            25.070.000         12.380.000         49.4
    ; Best Practice Network (BPN)        22            97.820.000         78.030.000         79.8

    ; TOTAL                             213           981.960.000        529.520.000
    ; AVG                                               4.610.141          2.486.009

    ;   Size-avg-CIP 17.3    ; not used as parameters (but important for calibration)
    ;   Size-stdev-CIP 8.95
    set Size-min-CIP 5
    set Size-max-CIP 58

    set Duration-avg-CIP 31.8
    set Duration-stdev-CIP 5.1
    ;   Duration-min-CIP 23
    ;   Duration-max-CIP 49

    set Contribution-avg-CIP 2.5  ; (the exact value is 2.486.009)
    ;   Contribution-stdev-CIP ?
    ;   Contribution-min-CIP 0.05   (50.000)
    ;   Contribution-max-CIP 15.4   (15.400.000)

    set Match-CIP 5  ; important for calibration

    ;   RES-avg-CIP ?
    set RES-min-CIP 0
    ;   RES-max-CIP ?

    ;   DFI-avg-CIP ?
    set DFI-min-CIP 0
    ;   DFI-max-CIP ?

    ;   SME-avg-CIP ?
    set SME-min-CIP 0
    ;   SME-max-CIP ?

    ;   CSO-avg-CIP ?
    set CSO-min-CIP item i [0 1]
    ;   CSO-max-CIP ?

    ; In the Baseline scenario the SCI/RRI score are not used.
    ; In contrast, the Balanced scenario applies equal weight to RRI/SCI scores when evaluating proposals.

    set RRI-criteria-CIP item i ["none" "all"]
    set RRI-min-CIP item i [0 10]
    set SCI-min-CIP item i [0 10]
    set RRI-balance-CIP item i [0 50]
  ]
  set i position Calls-settings ["no preset" "Baseline (CIP)" "with special caps"]
  if i > 0 [
    ; CIP data with regard to the EC contributions (which is available per instrument, and possibly per Call) can be used
    ; for setting the Baseline funding, which are expressed as percentages of the total funding (a global variable that
    ; can be changed in experiments)

    ; The earliest projects started in 2008, the last projects will end early 2016.
    ; With projects having an average duration of 31.84 months (2.65 years), and approx. 6 months between the closing of
    ; a Call and the start of its first project, it can be realistically assumed that proposals were submitted between
    ; between mid 2007 and mid 2012.

    ; For prototype development, we assume a series of 6 Calls with equal amount of funding available.

    ;               Start date      Funding      Percentage of
    ;                              available     total funding
    ;               ----------     ---------     -------------
    ;   Call1        mid 2007         88.3           16.7
    ;   Call2        mid 2008         88.3           16.7
    ;   Call3        mid 2009         88.3           16.7
    ;   Call4        mid 2010         88.3           16.7
    ;   Call5        mid 2011         88.3           16.7
    ;   Call6        mid 2012         88.3           16.7

    set i i - 1
    set Type-Call1 "CIP"     set Type-Call2 "CIP"     set Type-Call3 "CIP"
    set Deadline-Call1 6     set Deadline-Call2 18    set Deadline-Call3 30
    set Funding-Call1 16.7   set Funding-Call2 16.7   set Funding-Call3 16.7
    set Themes-Call1 10      set Themes-Call2 10      set Themes-Call3 10
    set Range-Call1 35       set Range-Call2 35       set Range-Call3 35
    set Orientation-Call1 5  set Orientation-Call2 5  set Orientation-Call3 5

    set Type-Call4 "CIP"     set Type-Call5 "CIP"     set Type-Call6 "CIP"
    set Deadline-Call4 42    set Deadline-Call5 54    set Deadline-Call6 66
    set Funding-Call4 16.7   set Funding-Call5 16.7   set Funding-Call6 16.7
    set Themes-Call4 10      set Themes-Call5 10      set Themes-Call6 10
    set Range-Call4 35       set Range-Call5 35       set Range-Call6 35
    set Orientation-Call4 5  set Orientation-Call5 5  set Orientation-Call6 5

    ; Only include special capabilities in the Call's cap-range if there are CSOs that have them
    set Special-caps? (i = 1)
  ]
  set i position Themes-settings ["no preset" "Baseline"]
  if i > 0 [
    ; The capability space is differentiated by 10 themes, partitioned as follows:
    ; ---------------------------------------------------------------------------------------------
    ; Theme    Sector capabilities   Common capabilities    Rare capabilities  Special capabilities
    ; ---------------------------------------------------------------------------------------------
    ;    1              1 -  40              41 -  80             81 -  90              91 - 100
    ;    2            101 - 140             141 - 180            181 - 190             191 - 200
    ;   ...              ...                   ...                  ...                   ...
    ;    9            801 - 840             841 - 880            881 - 890             891 - 900
    ;   10            901 - 940             941 - 980            981 - 990             991 -1000
    ; ---------------------------------------------------------------------------------------------

    set nCapabilities 1000
    set nThemes 10
    set sector-capabilities-per-theme 40
    set common-capabilities-per-theme 40
    set rare-capabilities-per-theme 10
    set special-capabilities-per-theme 10
    ; fill a list with all special capabilities
    set special-cap-list []
    let nr 1
    let capabilities-per-theme nCapabilities / nThemes  ; 100
    repeat nThemes [
      set nr nr + capabilities-per-theme - special-capabilities-per-theme
      repeat special-capabilities-per-theme [
        set special-cap-list lput nr special-cap-list
        set nr nr + 1
      ]
    ]
  ]
  set i position Other-settings ["no preset" "Baseline"]
  if i > 0 [
    set funding 529.5
    set project-cap-ratio 5
    set search-depth 20
    set invite-previous-partners-first? true
    set time-before-call-deadline 6
    set time-before-project-start 9
    set time-between-deliverables 3
    set max-deliverable-length 9
    set adjust-expertise-rate 0.0333
    set sub-nr-max 10
    set sub-size-min 3
  ]
end


to setup-globals
  set log? false
  set super? true
  set compute-network-distances? false
  set highest-proposal-nr 0
  set which-network "current and previous partners"
  set infinity 99999

  set proposals-count 0
  set proposals-with-SME-count 0
  set proposals-with-CSO-count 0
  set proposals-type []
  set proposals-call []
  set proposals-size []
  set proposals-RES []
  set proposals-DFI []
  set proposals-SME []
  set proposals-CSO []
  set proposals-anticipation []
  set proposals-participation []
  set proposals-reflexivity []
  set proposals-expertise-level []
  set proposals-capability-match []
  set proposals-RRI []
  set proposals-SCI []
  ;;;
  set proposals-size-Super []
  set proposals-RES-Super []
  set proposals-DFI-Super []
  set proposals-SME-Super []
  set proposals-CSO-Super []

  set projects-count 0
  set projects-with-SME-count 0
  set projects-with-CSO-count 0
  set projects-type []
  set projects-call []
  set projects-size []
  set projects-duration []
  set projects-contribution []
  set projects-RES []
  set projects-DFI []
  set projects-SME []
  set projects-CSO []
  set projects-anticipation []
  set projects-participation []
  set projects-reflexivity []
  set projects-responsiveness []
  set projects-expertise-level []
  set projects-capability-match []
  set projects-RRI []
  set projects-SCI []
  ;;;
  set projects-size-Super []
  set projects-RES-Super []
  set projects-DFI-Super []
  set projects-SME-Super []
  set projects-CSO-Super []

  set capabilities-RES []
  set capabilities-DFI []
  set capabilities-SME []
  set capabilities-CSO []
  set knowledge 0
  set knowledge-flow 0
  set kf-RES-to-RES 0  set kf-DFI-to-RES 0  set kf-SME-to-RES 0  set kf-CSO-to-RES 0
  set kf-RES-to-DFI 0  set kf-DFI-to-DFI 0  set kf-SME-to-DFI 0  set kf-CSO-to-DFI 0
  set kf-RES-to-SME 0  set kf-DFI-to-SME 0  set kf-SME-to-SME 0  set kf-CSO-to-SME 0
  set kf-RES-to-CSO 0  set kf-DFI-to-CSO 0  set kf-SME-to-CSO 0  set kf-CSO-to-CSO 0
  set kenes-length-RES []
  set kenes-length-DFI []
  set kenes-length-SME []
  set kenes-length-CSO []
  set patents 0
  set articles 0
  ;;;
  set kenes-length-RES-Super []
  set kenes-length-DFI-Super []
  set kenes-length-SME-Super []
  set kenes-length-CSO-Super []

  set run-data-participants-RES []
  set run-data-participants-RES-net []
  set run-data-participants-DFI []
  set run-data-participants-DFI-net []
  set run-data-participants-SME []
  set run-data-participants-SME-net []
  set run-data-participants-CSO []
  set run-data-participants-CSO-net []
  set run-data-proposals-submitted []
  set run-data-proposals []
  set run-data-proposals-with-SME []
  set run-data-proposals-with-CSO []
  set run-data-proposals-small []
  set run-data-proposals-big []
  set run-data-projects-started []
  set run-data-projects []
  set run-data-projects-with-SME []
  set run-data-projects-with-CSO []
  set run-data-projects-small []
  set run-data-projects-big []
  set run-data-network-density []
  set run-data-network-components []
  set run-data-network-largest-component []
  set run-data-network-avg-degree []
  set run-data-network-avg-path-length []
  set run-data-network-clustering []
  set run-data-knowledge []
  set run-data-knowledge-flow []
  set run-data-kf-RES-to-RES []  set run-data-kf-DFI-to-RES []  set run-data-kf-SME-to-RES []  set run-data-kf-CSO-to-RES []
  set run-data-kf-RES-to-DFI []  set run-data-kf-DFI-to-DFI []  set run-data-kf-SME-to-DFI []  set run-data-kf-CSO-to-DFI []
  set run-data-kf-RES-to-SME []  set run-data-kf-DFI-to-SME []  set run-data-kf-SME-to-SME []  set run-data-kf-CSO-to-SME []
  set run-data-kf-RES-to-CSO []  set run-data-kf-DFI-to-CSO []  set run-data-kf-SME-to-CSO []  set run-data-kf-CSO-to-CSO []
  set run-data-knowledge-patents []
  set run-data-knowledge-articles []
  set run-data-capabilities []
  set run-data-capabilities-diffusion []
  ;;;
  set run-data-participants-RES-Super []
  set run-data-participants-RES-net-Super []
  set run-data-participants-DFI-Super []
  set run-data-participants-DFI-net-Super []
  set run-data-participants-SME-Super []
  set run-data-participants-SME-net-Super []
  set run-data-participants-CSO-Super []
  set run-data-participants-CSO-net-Super []
  set run-data-proposals-small-Super []
  set run-data-proposals-big-Super []
  set run-data-projects-small-Super []
  set run-data-projects-big-Super []
  set run-data-capabilities-Super []
  set run-data-capabilities-diffusion-Super []
end


;;; EMPIRICAL CASE
;;;
;;; load greatcip data


to load-empirical-case [number-of-calls]
  ; open database
  sql:configure "defaultconnection" [
    ["user" "root"]
    ["password" ""]
    ["database" "greatcip?zeroDateTimeBehavior=convertToNull"]
  ]

  ; this routine calculates and stores participant size based on total CIP funding.
  ; This information is used later when the agents are created
  let participants-size-dict 0
  if not Empirical-case? [
    set participants-size-dict table:make
    ; get total CIP funding of all the participants
    sql:exec-query "SELECT ParticipantID, SUM(ParticipantECContribution) FROM ProjPart GROUP BY ParticipantID" []
    let all-participants sql:fetch-resultset
    let median-participant-funding median map [item 1 ?] all-participants
    while [not empty? all-participants] [
      ; step through the list of participants
      let row first all-participants
      set all-participants butfirst all-participants
      ; calculate participant size
      let participant-size 1
      let participant-funding item 1 row
      if participant-funding > 10 * median-participant-funding
        [ set participant-size ceiling (participant-funding / (10 * median-participant-funding)) ]
      table:put participants-size-dict (item 0 row) participant-size
    ]
  ]

  ; main routine, which retrieves the CIP projects and participants

  ; set the filter
  let call-ids ["CIP-ICT-PSP-YYYY-1" "CIP-ICT-PSP-YYYY-2" "CIP-ICT-PSP-YYYY-3" "CIP-ICT-PSP-YYYY-4" "CIP-ICT-PSP-YYYY-5" "CIP-ICT-PSP-YYYY-6"]
  let call-id-filter (word "('" item 0 call-ids "'")
  let i 1
  while [i < number-of-calls] [
    set call-id-filter (word call-id-filter ", '" item i call-ids "'")
    set i i + 1
  ]
  set call-id-filter (word call-id-filter ")")

  ; get the projects
  set i position Instrument-filter ["CIP" "all"]
  let psfs-filter "('CIP-ICT-PSP')"
  let sql-exec (word "SELECT ProjectNumber, ProjectAcronym, CallIdentifier, ProposalSubFundingScheme, ProjectStartDate, "
    "ProjectEndDate, ProjectECContribution FROM Project WHERE CallIdentifier IN " call-id-filter " AND ProposalSubFundingScheme IN " psfs-filter)
  sql:exec-direct sql-exec
  let all-projects sql:fetch-resultset

  let nr 1 ; for numbering participants
  let snr 1 ; for grouping participants (super-organisations)
  while [not empty? all-projects] [
    ; step through the list of projects
    let row first all-projects
    set all-projects butfirst all-projects

    print row

    let project-number item 0 row
    ; create a turtle for the new project
    let the-new-project nobody
    create-projects 1 [
      set the-new-project self
      set project-nr project-number        ; e.g. 248726
      set project-acronym item 1 row       ; e.g. +SPACES
      set project-call item 2 row          ; e.g. FP7-ICT-2009-4
      set project-type project-type-to-type item 3 row  ; e.g. CP-FP-INSFO -> STREP
      set project-start-date date-to-month correct-start-date project-nr (item 4 row)  ; e.g. 2010-01-01 -> 39
      set project-end-date date-to-month correct-end-date project-nr (item 5 row)      ; e.g. 2012-06-30 -> 69
      set project-contribution item 6 row
      set project-status ""
    ]

    ; get all the participants in the project
    sql:exec-query "SELECT ParticipantID FROM ProjPart WHERE ProjectNumber = ?" (list project-number)

    ; create an agentset of the members of this project
    let members nobody
    while [sql:row-available?] [
      let project-row sql:fetch-row
      let member one-of participants with [my-id = item 0 project-row]
      if member = nobody [
        ; this is a new participant - create 1 or more turtles for it
        ifelse Empirical-case? [
          ; 1 turtle only - participant size information is not used
          create-participants 1 [
            set my-nr nr
            set my-snr nr                    ; give turtle a unique snr
            set my-id item 0 project-row     ; e.g. 100364091
            set member self
            set nr nr + 1
          ]
        ] [
          ; 1 or more turtles - participant size information is used
          let participant-size table:get participants-size-dict item 0 project-row
          create-participants participant-size [
            set my-nr nr
            set my-snr snr                   ; give turtles the same snr
            set my-id item 0 project-row     ; e.g. 100364091
            set member self
            set nr nr + 1
          ]
          set snr snr + 1
        ]
      ]
      set members (turtle-set members member)
    ]

    ; the project consortium
    ask the-new-project [ set project-consortium members ]
  ]

  ; add participant name and org. type to participant turtles

  ask participants [
    sql:exec-query "SELECT ParticipantShortName, OrganisationType, SMEFlag FROM Participant WHERE ParticipantID = ?" (list my-id)
    let row sql:fetch-row
    set my-name item 0 row                 ; e.g. IBM ISRAEL
    set my-type participant-type-to-type item 1 row item 2 row  ; e.g. PRC & N -> dfi
    set my-proposals no-turtles
    set my-projects no-turtles
    set my-partners no-turtles
    set my-previous-partners no-turtles
    set my-capabilities []
    set my-abilities []
    set my-expertises []
    set my-orientations []
    set participation-in-proposals []
    set participation-in-projects []
  ]
end


; Starting network
; ----------------
; We fill the list of previous partners with consortium partners of the first calls before the cutoff point.
; This is an approximation of the starting network.

to make-starting-network
  let call-ids ["CIP-ICT-PSP-YYYY-1" "CIP-ICT-PSP-YYYY-2" "CIP-ICT-PSP-YYYY-3" "CIP-ICT-PSP-YYYY-4" "CIP-ICT-PSP-YYYY-5" "CIP-ICT-PSP-YYYY-6"]
  ask projects with [position project-call call-ids < cutoff-point] [
    let the-consortium project-consortium
    ask the-consortium [
      set my-previous-partners (turtle-set my-previous-partners (the-consortium with [self != myself]))
    ]
  ]
end


; correct any missing values identified in the database

to-report correct-start-date [the-project-nr the-start-date]
  if the-project-nr = 270447
    [ report "2011-04-01" ]
  report the-start-date
end


to-report correct-end-date [the-project-nr the-end-date]
  if the-project-nr = 270447
    [ report "2014-09-30" ]
  report the-end-date
end


; convert from full date YYYY-MM-DD to month:
; 2006-11-DD -> 0, 2006-12-DD -> 1 etc.

to-report date-to-month [the-date]
  if not is-string? the-date [ report 0 ] ; intercept <null>
  let the-year substring the-date 0 4
  let the-month substring the-date 5 7
  let months 12 * position the-year ["2006" "2007" "2008" "2009" "2010" "2011" "2012" "2013" "2014" "2015" "2016"]
  set months months + position the-month ["01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"]
  report months - 11
end


; convert from CIP-type to SKIN-type

to-report project-type-to-type [cip-type]
  if cip-type = "CIP-ICT-PSP"
    [ report "CIP" ]
  report "OTH"
end


to-report participant-type-to-type [infso-type sme-flag]
  if infso-type = "HES" or infso-type = "REC"
    [ report "res" ]
  if infso-type = "PRC" [
    ifelse sme-flag = "Y"
      [ report "sme" ]
      [ report "dfi" ]
  ]
  report "oth"
  ; TO DO: "CSO"
end


;;; PARTICIPANTS
;;;
;;; initialise participants, make kenes


; make participants as empty shells, yet to filled with knowledge

to initialise-participants
  set participants-dict table:make
  ask participants [ table:put participants-dict my-nr self ]
  let nRES round (Perc-RES * nParticipants / 100)
  let nDFI round (Perc-DFI * nParticipants / 100)
  let nSME round (Perc-SME * nParticipants / 100)
  let nCSO round (Perc-CSO * nParticipants / 100)
  let nr 1 + count participants
  ; research institutes (including universities)
  create-participants nRES - length remove-duplicates [my-snr] of participants with [my-type = "res"] [
    set my-nr nr
    set my-snr nr
    set my-type "res"

    table:put participants-dict my-nr self
    set nr nr + 1
    hide-turtle
  ]
  ; diversified firms
  create-participants nDFI - length remove-duplicates [my-snr] of participants with [my-type = "dfi"] [
    set my-nr nr
    set my-snr nr
    set my-type "dfi"

    table:put participants-dict my-nr self
    set nr nr + 1
    hide-turtle
  ]
  ; SMEs
  create-participants nSME - length remove-duplicates [my-snr] of participants with [my-type = "sme"] [
    set my-nr nr
    set my-snr nr
    set my-type "sme"

    table:put participants-dict my-nr self
    set nr nr + 1
    hide-turtle
  ]
  ; CSOs
  create-participants nCSO - length remove-duplicates [my-snr] of participants with [my-type = "cso"] [
    set my-nr nr
    set my-snr nr
    set my-type "cso"

    table:put participants-dict my-nr self
    set nr nr + 1
    hide-turtle
  ]
  ask participants [ initialise-participant ]
end


; initialise all the participant's variables (except my-type and my-cap-capacity, previously set)

; Important Remark concerning the initialisation of SMEs and CSOs
; ---------------------------------------------------------------
; We discussed the important meaning of SMEs concerning their contribution to radical research.
; New knowledge is injected into the system most often by new, small and sophisticated companies.
; Therefore, we should design SMEs with this rare knowledge. We structure the knowledge space
; (e.g. 1000 different capabilities) by allocating e.g. 100 capabilities to each of the CIP-ICT-PSP
; themes. In order to allow the SMEs to play their special role we define 10 capabilities per
; theme as 'rare' capabilities and give these capabilities in the starting distribution exclusively
; to SMEs. We also define 10 capabilities per theme as 'special' capabilities and give these
; capabilities exclusively to CSOs.

;participant procedure
to initialise-participant
  set my-name ""
  set my-proposals no-turtles
  set my-projects no-turtles
  set my-partners no-turtles
  set my-previous-partners no-turtles
  set my-capabilities []
  set my-abilities []
  set my-expertises []
  set my-orientations []
  set participation-in-proposals []
  set participation-in-projects []
end


;participant procedure
to make-kene
  ; Set cap-capacity depending on type
  if (my-type = "dfi") [ set my-cap-capacity Size-DFI ]
  if (my-type = "sme") [ set my-cap-capacity Size-SME ]
  if (my-type = "res") [ set my-cap-capacity Size-RES ]
  if (my-type = "cso") [ set my-cap-capacity Size-CSO ]

  ; Fill the capability vector with capabilities. These are integers between 1 and nCapabilities, such
  ; that no number is repeated.
  ; First, fill half of the capability vector with sector capabilities
  while [length my-capabilities < my-cap-capacity * 0.5] [
    let candidate-capability pick-sector-capability
    if (not member? candidate-capability my-capabilities) [
      set my-capabilities lput candidate-capability my-capabilities
    ]
  ]
  ; SMEs should have at least one rare capability
  if (my-type = "sme")
    [ set my-capabilities lput pick-rare-capability my-capabilities ]
  ; CSOs should have at least one special capability
  if (my-type = "cso")
    [ set my-capabilities lput pick-special-capability my-capabilities ]
  ; Fill the capability vector with common capabilities
  while [length my-capabilities < my-cap-capacity] [
    let candidate-capability pick-common-capability
    if (not member? candidate-capability my-capabilities) [
      set my-capabilities lput candidate-capability my-capabilities
    ]
  ]

  ; Fill the ability and expertise vectors with real numbers randomly chosen from 0 .. <10 for abilities
  ; and integers from 1 .. 10 for expertise levels
  while [length my-abilities < length my-capabilities] [
    set my-abilities lput random-float 10.0 my-abilities
    set my-expertises lput (1 + random 10) my-expertises
  ]

  ; We extend the capabilities, abilities and expertise by a research orientation, which is represented by
  ; an integer between 0 and 9 (0 corresponds to a full basic research orientation; 9 corresponds to a
  ; full applied research orientation)
  while [length my-orientations < length my-capabilities] [
    ifelse (my-type = "res")
      [ set my-orientations lput random 5 my-orientations ]
      [ set my-orientations lput (5 + random 5) my-orientations ]
  ]
end


; ---------------------------------------------------------------------------------------------
; Theme    Sector capabilities   Common capabilities    Rare capabilities  Special capabilities
; ---------------------------------------------------------------------------------------------
;    1              1 -  40              41 -  80             81 -  90              91 - 100
;    2            101 - 140             141 - 180            181 - 190             191 - 200
;   ...              ...                   ...                  ...                   ...
;    9            801 - 840             841 - 880            881 - 890             891 - 900
;   10            901 - 940             941 - 980            981 - 990             991 -1000
; ---------------------------------------------------------------------------------------------

to-report pick-sector-capability
  let theme 1 + random (count themes)  ; 1 .. 10
  let sector-capability 1 + random sector-capabilities-per-theme  ; 1 .. 40
  let capabilities-per-theme nCapabilities / count themes  ; 100
  report sector-capability + (theme - 1) * capabilities-per-theme
end


to-report pick-common-capability
  let theme 1 + random (count themes)  ; 1 .. 10
  let common-capability 1 + random common-capabilities-per-theme  ; 1 .. 40
  set common-capability common-capability + sector-capabilities-per-theme  ; 41 .. 80
  let capabilities-per-theme nCapabilities / count themes  ; 100
  report common-capability + (theme - 1) * capabilities-per-theme
end


to-report pick-rare-capability
  let theme 1 + random (count themes)  ; 1 .. 10
  let rare-capability 1 + random rare-capabilities-per-theme  ; 1 .. 10
  set rare-capability rare-capability + sector-capabilities-per-theme + common-capabilities-per-theme  ; 81 .. 90
  let capabilities-per-theme nCapabilities / count themes  ; 100
  report rare-capability + (theme - 1) * capabilities-per-theme
end


to-report pick-special-capability
  let theme 1 + random (count themes)  ; 1 .. 10
  let special-capability 1 + random special-capabilities-per-theme  ; 1 .. 10
  let capabilities-per-theme nCapabilities / count themes  ; 100
  set special-capability special-capability + capabilities-per-theme - special-capabilities-per-theme  ; 91 .. 100
  report special-capability + (theme - 1) * capabilities-per-theme
end


to make-super-organisations
  ; random groups (for test only)
  ask participants [
    if my-type = "res" [ set my-snr 10 + random 10 ]
    if my-type = "dfi" [ set my-snr 20 + random 10 ]
    if my-type = "sme" [ set my-snr 30 + random 10 ]
    if my-type = "cso" [ set my-snr 40 + random 10 ]
  ]
end


;;; GO
;;;
;;; main loop, 3 stages


to go
  if ticks = nMonths
    [ stop ]

  set knowledge-flow 0

  ; Stage 1 - Agents develop proposals
  ; Stage 2 - Proposals are evaluated
  ; Stage 3 - Consortia carry out projects

  ifelse Empirical-case? [
    ; Empirical case - Stage 3 only
    ask projects [
      start-project
      finish-project
    ]
    dissolve-projects
  ] [
    ; Simulation - Stage 1
    if log? [ log-stage1 ]
    publish-calls
    if log? [ log-calls ]
    ask participants [
      initiate-proposals
      find-partners
      submit-proposals
    ]
    if log? [ log-proposals ]
    close-calls

    ; Simulation - Stage 2
    if log? [ log-stage2 ]
    evaluate-calls  ; after computing their RRI/SCI-scores
    if log? [ log-evaluation ]
    dissolve-proposals
    if log? [ log-projects ]

    ; Simulation - Stage 3
    ask projects [
      start-project
      learn-from-partners
      do-research
      make-deliverables
      finish-project
    ]
    adjust-expertise-levels

    ; Simulation - Stage 4
    evaluate-projects  ; after computing their RRI/SCI-scores
    dissolve-projects
  ]

  tick
  ; update-network-measures is computionally expensive and is commented out (but not
  ; deleted because it could be useful for demos that work with small agentsets)
  ;if ticks mod update-network-measures-interval = 0
  ;  [ update-network-measures ]
  if not Empirical-case?
    [ update-knowledge-measures ]
  update-the-plots
  update-run-data

  ; if the run is part a BehaviorSpace experiment (run-number > 0) then export to simdb
  ; otherwise export to workdir
  export-network-data (behaviorspace-run-number > 0)
  if not Empirical-case?
    [ export-knowledge-data (behaviorspace-run-number > 0) ]
  if ticks = nMonths
    [ export-run-data (behaviorspace-run-number > 0) ]
end


to log-stage1
  if log? [
    print "" print ""
    print (word "TICKS " ticks) print "STAGE 1" print "-------"
    print "" print ""
  ]
end


to log-calls
  if log? [
    print "" print "CALLS:"
    foreach sort-by [[call-nr] of ?1 < [call-nr] of ?2] calls [
      type "  "
      if [call-nr] of ? < 10 [ type " " ]
      print (word [call-nr] of ? "   " [call-type] of ? "   " [call-status] of ?)
    ]
    print "" print ""
  ]
end


to log-proposals
  if log? [
    print "" print "PROPOSALS:"
    foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [
      type "  "
      if [my-nr] of ? < 10 [ type " " ]
      if [my-nr] of ? < 100 [ type " " ]
      type (word [my-nr] of ? "   " [my-type] of ? "   " count [my-proposals] of ? " ")
      ask [my-proposals] of ? [
        type (word "  " proposal-nr)
        if proposal-coordinator = ? [ type "C" ]
      ]
      print (word "  " [room-for-another-proposal?] of ?)
    ]
    print "" print ""
  ]
end


to log-stage2
  if log? [
    print "" print ""
    print (word "TICKS " ticks) print "STAGE 2" print "-------"
    print "" print ""
  ]
end


to log-evaluation
  if log? [
    print "" print "EVALUATION:"
    foreach sort-by [[proposal-ranking-nr] of ?1 < [proposal-ranking-nr] of ?2] proposals [
      type "  "
      ; proposal nr
      let col1 [proposal-nr] of ?
      if col1 < 10 [ type " " ]
      if col1 < 100 [ type " " ]
      type (word col1 " ")
      ; ranking nr
      let col2 [proposal-ranking-nr] of ?
      if col2 < 10 [ type " " ]
      if col2 < 100 [ type " " ]
      type (word col2 " ")
      ; consortium size
      type " "
      let col3 count [proposal-consortium] of ?
      if col3 < 10 [ type " " ]
      type (word col3 " ")
      ; average expertise level
      let col4 [expertise-level-score] of ?
      set col4 round (10 * col4) / 10
      if col4 < 10 [ type " " ]
      type (word col4 " ")
      if col4 = round col4 [ type "  " ]
      ; capability match
      let col5 [capability-match-score] of ?
      if col5 < 10 [ type " " ]
      type (word col5 " ")
      ; status
      let col6 [proposal-status] of ?
      print (word "  " col6)
    ]
    print "" print ""
  ]
end


to log-projects
  if log? [
    print "" print "PROJECTS:"
    foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [
      type "  "
      if [my-nr] of ? < 10 [ type " " ]
      if [my-nr] of ? < 100 [ type " " ]
      type (word [my-nr] of ? "   " [my-type] of ? "   " count [my-projects] of ? " ")
      ask [my-projects] of ? [ type (word "  " project-nr) ]
      print ""
    ]
    print "" print ""
  ]
end


;;; THEMES
;;;
;;; structure the knowledge space (8 INFSO themes)


;observer procedure
to initialise-themes
  let nr 1
  set themes-dict table:make
  create-themes nThemes [
    set theme-nr nr
    set theme-description (word "ICT" nr)

    table:put themes-dict theme-description self
    hide-turtle
    set nr nr + 1
  ]
end


;;; INSTRUMENTS
;;;
;;; create instruments


;observer procedure
to initialise-instruments
  let nr 1
  set instruments-dict table:make
    create-instruments 1 [
    set instr-nr nr
    set instr-type "CIP"
    set instr-size-min Size-min-CIP
    set instr-size-max Size-max-CIP
    set instr-duration-avg Duration-avg-CIP
    set instr-duration-stdev Duration-stdev-CIP
    set instr-contribution Contribution-avg-CIP
    set instr-match Match-CIP
    set instr-sub-nr-max sub-nr-max
    set instr-sub-size-min sub-size-min
    set instr-RES-min RES-min-CIP
    set instr-DFI-min DFI-min-CIP
    set instr-SME-min SME-min-CIP
    set instr-CSO-min CSO-min-CIP
    set instr-RRI-criteria RRI-criteria-CIP
    set instr-RRI-min RRI-min-CIP
    set instr-SCI-min SCI-min-CIP
    set instr-RRI-balance RRI-balance-CIP

    table:put instruments-dict instr-type self
    hide-turtle
    set nr nr + 1
  ]
end


;;; CALLS
;;;
;;; publish new calls


; The calls of the Commission specify:
; - type of instrument (STREP etc.) -> the instrument type specifies minimum number of partners,
;   composition of partners, and the length of the project.
; - date of call (to determine the deadline for submission)
; - a range of capabilities (at least one of which must appear in an eligible proposal)
; - the number of projects that will be funded
; - the desired basic or applied orientation
;
; When a new call is published, the deadline for a proposal is six months away, i.e. the agents
; have six time steps to set up a consortium and to 'write a proposal'. Or the length of research
; projects (e.g. three years) and therefore the possibilities of consortium members to improve
; and exchange knowledge is given by e.g. 36 iterations.


;observer procedure
to initialise-calls
  let nr 1
  set calls-dict table:make
  create-calls 1 [
    set call-nr nr  set call-type Type-Call1  set call-id nr  set call-publication-date Deadline-Call1 - time-before-call-deadline  set call-deadline Deadline-Call1
    set call-funding Funding-Call1 set call-themes Themes-Call1  set call-orientation Orientation-Call1  set call-range Range-Call1  set call-special-caps? Special-caps?
    set call-capabilities []  set call-status ""  set call-evaluated? false  set call-counter table:make

    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
  create-calls 1 [
    set call-nr nr  set call-type Type-Call2  set call-id nr  set call-publication-date Deadline-Call2 - time-before-call-deadline  set call-deadline Deadline-Call2
    set call-funding Funding-Call2 set call-themes Themes-Call2  set call-orientation Orientation-Call2  set call-range Range-Call2  set call-special-caps? Special-caps?
    set call-capabilities []  set call-status ""  set call-evaluated? false  set call-counter table:make

    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
  create-calls 1 [
    set call-nr nr  set call-type Type-Call3  set call-id nr  set call-publication-date Deadline-Call3 - time-before-call-deadline  set call-deadline Deadline-Call3
    set call-funding Funding-Call3 set call-themes Themes-Call3  set call-orientation Orientation-Call3  set call-range Range-Call3  set call-special-caps? Special-caps?
    set call-capabilities []  set call-status ""  set call-evaluated? false  set call-counter table:make

    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
  create-calls 1 [
    set call-nr nr  set call-type Type-Call4  set call-id nr  set call-publication-date Deadline-Call4 - time-before-call-deadline  set call-deadline Deadline-Call4
    set call-funding Funding-Call4 set call-themes Themes-Call4  set call-orientation Orientation-Call4  set call-range Range-Call4  set call-special-caps? Special-caps?
    set call-capabilities []  set call-status ""  set call-evaluated? false  set call-counter table:make

    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
  create-calls 1 [
    set call-nr nr  set call-type Type-Call5  set call-id nr  set call-publication-date Deadline-Call5 - time-before-call-deadline  set call-deadline Deadline-Call5
    set call-funding Funding-Call5 set call-themes Themes-Call5  set call-orientation Orientation-Call5  set call-range Range-Call5  set call-special-caps? Special-caps?
    set call-capabilities []  set call-status ""  set call-evaluated? false  set call-counter table:make

    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
  create-calls 1 [
    set call-nr nr  set call-type Type-Call6  set call-id nr  set call-publication-date Deadline-Call6 - time-before-call-deadline  set call-deadline Deadline-Call6
    set call-funding Funding-Call6 set call-themes Themes-Call6  set call-orientation Orientation-Call6  set call-range Range-Call6  set call-special-caps? Special-caps?
    set call-capabilities []  set call-status ""  set call-evaluated? false  set call-counter table:make

    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
  ; repeat the last call 6 times (optional)
  if Repeat-last-call? [
    let deadline Deadline-Call6
    create-calls 6 [
      set deadline deadline + 6
      set call-nr nr  set call-type Type-Call6  set call-id nr  set call-publication-date deadline - time-before-call-deadline  set call-deadline deadline
      set call-funding Funding-Call6 set call-themes Themes-Call6  set call-orientation Orientation-Call6  set call-range Range-Call6
      set call-capabilities []  set call-status ""  set call-evaluated? false  set call-counter table:make

      table:put calls-dict call-id self
      hide-turtle
      set nr nr + 1
    ]
  ]
end


; in the Baseline scenario, special capabilities are excluded from the Call's cap-range

;Call procedure
to make-cap-range
  ; Fill the capability vector with capabilities.
  ; These are integers between 1 and nCapabilities, such that no number is repeated
  ; First, if special-caps? is true, the Call should have at least one special capability
  if call-special-caps?
    [ set call-capabilities lput pick-special-capability call-capabilities ]
  ; Fill the capability vector
  while [length call-capabilities < call-range] [
    let candidate-capability (random (call-themes * 100)) + 1
    if (not member? candidate-capability call-capabilities) [
      let is-special-cap? member? candidate-capability special-cap-list
      ifelse (is-special-cap? and (not call-special-caps?))
        [ ]  ; do nothing (exclude special caps)
        [ set call-capabilities lput candidate-capability call-capabilities ]
    ]
  ]
end


;observer procedure
to publish-calls
  ask calls with [call-publication-date = ticks] [
    set call-status "open"
    ; to keep things simple, we assume that the calls are not overlapping
    set the-current-call self
  ]
end


;observer procedure
to close-calls
  ask calls with [call-deadline = ticks + 1] [ set call-status "closed" ]
end


; notify the call about the changed status of the proposal. This is for measuring the process
; in response to the call only
;
; here is an example:
; Call 1 is notified about the change that a proposal is "submitted". This procedure updates
; the table of Call 1, increasing the number of submitted proposals.
; If this is the first proposal that is submitted for the Call, the table key "submitted" does
; not exist and thus cannot be read. In this case, the new key is mapped to the value 1

; proposal procedure
to notify-changed-status
  let the-updated-value 1
  let the-counter [call-counter] of table:get calls-dict proposal-call
  if (table:has-key? the-counter proposal-status)
    [ set the-updated-value (table:get the-counter proposal-status) + 1 ]
  table:put the-counter proposal-status the-updated-value
end


;;; PROPOSALS & RESEARCH CONSORTIA
;;;
;;; initiate proposals, invite partners, formulate and submit proposals


; Initiation of Proposals
; -----------------------
; Proposals are (most often) initiated by research institutes. The possibility to initiate a
; proposal depends on the length of the kene. We assume that a project or one proposal requires
; at minimum the kene length of an SME (which is five quadruples). (From this follows that the
; number of proposals a research institute can initiate depends on the length of its kene
; divided by the minimum length of the kene of an SME.)
;
; As each agent cannot be engaged in an extensive number of projects and proposal writings the
; number of initiated proposals follows:
; (length of the kene) / (minimum length of an SME kene) � (the number of existing projects)
;
; To summarise:
; the number of new proposals initiated depends on
;   1. size (~ kene length)
;   2. existing projects

;participant procedure
to initiate-proposals
  if my-type = "res" [
    let the-call one-of calls with [call-status = "open"]
    if the-call != nobody [ initiate-proposal the-call ]
  ]
end


; participant procedure
to-report room-for-another-proposal?
  report (length my-capabilities / project-cap-ratio) - (count my-proposals + count my-projects) > 0
end


; make an 'empty' proposal

;participant procedure
to-report make-proposal
  let the-new-proposal nobody
  hatch-proposals 1 [
    set the-new-proposal self
    set proposal-nr highest-proposal-nr + 1
    set proposal-consortium no-turtles
    set proposal-status "initiated"
    set proposal-ranking-nr 0
    set anticipation-score 0
    set participation-score 0
    set reflexivity-score 0
    set capability-match-score 0
    set expertise-level-score 0
    set RRI-score 0
    set SCI-score 0
    set proposal-capabilities []
    set proposal-abilities []
    set proposal-expertises []
    set proposal-orientations []
    set proposal-contributors []
    set highest-proposal-nr proposal-nr
  ]
  report the-new-proposal
end


; if enough room initiate one proposal (RES only)

; participant procedure
to initiate-proposal [the-call]
  let n 1
  repeat n [
    ifelse room-for-another-proposal? [
      let relevant-capabilities intersection my-capabilities [call-capabilities] of the-call
      if (not empty? relevant-capabilities) [
        let the-new-proposal make-proposal
        if log? [
          type (word "I am participant " my-nr " (" my-type ") (in " count my-proposals " proposals). ")
          print (word "I am initiating a new proposal " [proposal-nr] of the-new-proposal ".")
        ]
        ask the-new-proposal [
          set proposal-type [call-type] of the-call
          set proposal-call [call-id] of the-call
          set proposal-coordinator myself
          notify-changed-status
        ]
        join the-new-proposal
      ]
    ]
    [ if log? [ print (word "I have no 'room' for initiating a new proposal.") print "" ] ]
  ]
end


; A proposal is a compilation of kene quadruples of agents in the proposal consortium.
; - Each agent is contributing one capability to the proposal.
; - If the agent has a capability which is specified in the call he contributes this capability.
; - If the agent possesses more than one capability outlined in the call we randomly choose
;   one of these capabilities.
;
; The possibilities to join a proposal consortium are determined by the same rules we applied
; for the determination of project initiations. The length of the kene determines whether the
; agent has free capacities for new activities, e.g. a SME, whose kene is of minimum size
; (i.e. five quadruples) and which is already in a project or a proposal initiative has to
; reject the offer.


;participant procedure
to join [the-proposal]
  if log? [ type (word "I am participant " my-nr " (" my-type "). I am invited to join proposal " [proposal-nr] of the-proposal ". ") ]
  ifelse room-for-another-proposal? [
    ; randomly choose capabilities to contribute
    let the-call table:get calls-dict [proposal-call] of the-proposal
    let relevant-capabilities intersection my-capabilities [call-capabilities] of the-call
    ; note that relevant-capabilities may contain duplicates
    ifelse not empty? relevant-capabilities [
      if log? [ print "I accept." ]
      let n my-cap-capacity / project-cap-ratio  ; "room" for adding capabilities
      while [n > 0 and not empty? relevant-capabilities] [
        let capability one-of relevant-capabilities
        let location position capability my-capabilities
        ; TO DO: "position" reports the first position of the capability in my-capabilities, yet the capability
        ; might appear more than once in my-capabilities.
        ; add a kene quadruple to the proposal
        ask the-proposal [
          set proposal-capabilities lput capability proposal-capabilities
          set proposal-abilities lput (item location [my-abilities] of myself) proposal-abilities
          set proposal-expertises lput (item location [my-expertises] of myself) proposal-expertises
          set proposal-orientations lput (item location [my-orientations] of myself) proposal-orientations
          ; who added the kene quadruple?
          set proposal-contributors lput ([my-nr] of myself) proposal-contributors
        ]
        set relevant-capabilities remove capability relevant-capabilities
        ; all instances of capability (including duplicates) are removed
        set n n - 1
      ]
      ; become a consortium partner
      ask the-proposal [ set proposal-consortium (turtle-set proposal-consortium myself) ]
      set my-proposals (turtle-set my-proposals the-proposal)
    ]
    [ if log? [ type (word "I have no relevant capabilities for joining this proposal. ") print "I decline." ] ]
  ]
  [ if log? [ type (word "I have no 'room' for joining the new proposal. ") print "I decline." ] ]
end


; Partner Search
; --------------
; First, the agent looks on the list of his previous partners.
; Second, previous partners, who agreed to join the proposal, can add previous partners
; from their list.
; Third, new partners will be searched for.
; The search process is guided by the requirements outlined in the call. These requirements
; are a list of capabilities and the proposal is considered to be eligible only, if at minimum
; one of these capabilities appears.
; If no agent from the list of previous partners can contribute such a capability in the first
; iteration, than in the second iteration previous partners of those agents who agreed to join
; the proposal can ask their previous partners. If the required capability is not found, the
; proposal consortium can search for the knowledge in the population of all actors. This is
; done on a random basis. In every iteration n agents can be asked whether they have the
; respective capability and whether they want to join the proposal consortium.


;participant procedure
to find-partners
  foreach [self] of my-proposals with [proposal-status = "initiated" and proposal-coordinator = myself]
    [ find-possible-partners ? ]
end


;participant procedure
to find-possible-partners [the-proposal]
  if log? [
    type (word "I am participant " my-nr " (" my-type "). ")
    type (word "I am coordinator of proposal " [proposal-nr] of the-proposal ". ")
    print "I am searching possible partners for this proposal."
  ]

  let nr 0
  let possible-partners []
  let declined [] ; if declined, do not ask again

  if invite-previous-partners-first? [
    ; 1st iteration - search previous partners
    set possible-partners [self] of my-previous-partners ; of the coordinator
    ; the search
    set nr 0
    while [(not ready-to-submit? the-proposal) and (length possible-partners > 0) and (nr < search-depth)] [
      let a-possible-partner one-of possible-partners
      ask a-possible-partner [ join the-proposal ]
      set possible-partners remove a-possible-partner possible-partners
      if (not member? a-possible-partner [proposal-consortium] of the-proposal)
        [ set declined lput a-possible-partner declined ]
      set nr nr + 1
    ]

    ; 2nd iteration - previous partners can add their previous partners
    let previous-partners no-turtles
    ask my-previous-partners [ set previous-partners (turtle-set previous-partners my-previous-partners) ]
    set possible-partners [self] of previous-partners with [not member? self [proposal-consortium] of the-proposal]
    set possible-partners difference declined possible-partners
    ; the search (same as above)
    set nr 0
    while [(not ready-to-submit? the-proposal) and (length possible-partners > 0) and (nr < search-depth)] [
      let a-possible-partner one-of possible-partners
      ask a-possible-partner [ join the-proposal ]
      set possible-partners remove a-possible-partner possible-partners
      if not member? a-possible-partner [proposal-consortium] of the-proposal
        [ set declined lput a-possible-partner declined ]
      set nr nr + 1
    ]
  ]

  ; 3rd iteration - search new partners
  set possible-partners [self] of participants with [not member? self [proposal-consortium] of the-proposal]
  set possible-partners difference declined possible-partners
  ; the search (same as above)
  set nr 0
  while [(not ready-to-submit? the-proposal) and (length possible-partners > 0) and (nr < search-depth)] [
    let a-possible-partner one-of possible-partners
    ask a-possible-partner [ join the-proposal ]
    set possible-partners remove a-possible-partner possible-partners
    if not member? a-possible-partner [proposal-consortium] of the-proposal
      [ set declined lput a-possible-partner declined ]
    set nr nr + 1
  ]
end


; reporter for the ranking the potential partners on attractiveness.
; the search for new partners in the 3rd iteration requires a concept of what makes for an attractive
; potential partner. Relevant factors for attractiveness include a participant's type, size (kene length),
; rare capabilities, research orientation, thematic orientation, position in the network, etc.

; WARNING: A sort on 3000 participants is computationally expensive and is consequently not used.

to-report attractiveness-comparator? [a-potential-partner another-potential-partner]
  ; 1st ranking order - Average expertise level of the potential partners
  ; 2nd ranking order - Desired research orientation of the potential partners
  ; 3rd ranking order - Randomly decide on the ranking
  if [mean my-expertises] of a-potential-partner > [mean my-expertises] of another-potential-partner [ report true ]
  if [mean my-expertises] of a-potential-partner = [mean my-expertises] of another-potential-partner
    [
      if [mean my-orientations] of a-potential-partner > [mean my-orientations] of another-potential-partner [ report true ]
      if [mean my-orientations] of a-potential-partner = [mean my-orientations] of another-potential-partner [ report random 2 = 1 ]
    ]
  report false
end


; A proposal will be submitted if at least one capability appears. Otherwise the process is
; stopped and the agents may start a new initiative.

;participant procedure
to submit-proposals
  ask my-proposals with [proposal-status = "initiated" and proposal-coordinator = myself] [
    if log? [ type (word "I am participant " [my-nr] of myself ". ") ]
    ifelse ready-to-submit? self [
      if log? [ print "I am submitting this proposal." print "" ]
      set proposal-status "submitted"
      notify-changed-status
    ] [
      if log? [ print "I am stopping this proposal." print "" ]
      set proposal-status "stopped"
      notify-changed-status
      dissolve-proposal
    ]
  ]
end


; reports the set intersection of the lists a and b, treated as sets

; the intersection A ∩ B of two sets A and B is the set that contains
; all elements of A that also belong to B, or equivalently,
; all elements of B that also belong to A

to-report intersection [set-a set-b]
  let set-c []
  foreach set-a [ if member? ? set-b [ set set-c lput ? set-c ] ]
  report set-c
end


; reports the difference of lists a and b, treated as sets

; the symmetric difference of two sets is the set of elements which are
; in either of the sets and not in their intersection

; TO DO: "treated as sets" - does it imply that the two sets are
; considered not to contain duplicates?

to-report difference [set-a set-b]
  let set-c intersection set-a set-b
  set set-b remove-duplicates (sentence set-a set-b)
  foreach set-c [ if member? ? set-b [ set set-b remove ? set-b ] ]
  report set-b
end


;;; EVALUATION OF PROPOSALS
;;;
;;; evaluate (reject or accept) proposals


; Evaluation of calls
; -------------------
; Proposals have to fulfil the hard criteria to be considered as eligible, otherwise they are rejected.
; Hard factors are: sufficient partners with the desired research orientation.
; Concerning the desired research orientation the following rule will be applied: The Commission asks
; in their calls for a research orientation of a certain value; e.g. a more applied research project
; requires a research orientation of the consortium above 7.5. This value is computed as the average
; of the individual research orientations.
; Also a hard factor for a proposal to be considered as eligible is the requirement that at least one
; of the capabilities specified in the call appear in the proposal.


;observer procedure
to evaluate-calls
  ask calls with [call-status = "closed" and call-evaluated? = false] [
     evaluate-proposals
     set call-evaluated? true
  ]
end


;call procedure
to evaluate-proposals
  ; look at all submitted proposals - which proposals are eligible?
  let the-submitted-proposals proposals with [proposal-status = "submitted" and proposal-call = [call-id] of myself]
  ask the-submitted-proposals [
    ifelse eligible? self
      [ set proposal-status "eligible" ]
      [ set proposal-status "ineligible" ]
    notify-changed-status
  ]
  ; look at all eligible proposals - which proposals get highest ranking?
  let the-eligible-proposals the-submitted-proposals with [proposal-status = "eligible"]
  ; the number of proposals that are accepted depends on the funding available for this call
  let threshold rank the-eligible-proposals ((call-funding / 100) * funding)
  ask the-eligible-proposals [
    ifelse proposal-ranking-nr <= threshold
      [ set proposal-status "accepted" ]
      [ set proposal-status "rejected" ]
    notify-changed-status
  ]
end


;observer procedure
to-report eligible? [the-proposal]
  let the-instrument table:get instruments-dict [proposal-type] of the-proposal
  let i position [instr-RRI-criteria] of the-instrument ["none" "all"]
  ifelse i = 0 [
    ; RRI/SCI scores are NOT used for eligibility check
    let the-consortium [proposal-consortium] of the-proposal
    ; consortium too small or too big?
    if (count the-consortium < [instr-size-min] of the-instrument)
      [ report false ]
    if (count the-consortium > [instr-size-max] of the-instrument)
      [ report false ]
    ; 1st hard factor - sufficient partners with the desired research orientation
    let the-call table:get calls-dict [proposal-call] of the-proposal
    if (mean [proposal-orientations] of the-proposal < [call-orientation] of the-call)
      [ report false ]
    ; 2nd hard factor - sufficient capabilities specified in the call appear in the proposal
    if capability-match the-proposal < [instr-match] of the-instrument
      [ report false ]
    ; OK for all factors
    report true
  ] [
    ; RRI/SCI scores are used
    ask the-proposal [
      set anticipation-score compute-anticipation-score self
      set participation-score compute-participation-score self
      set reflexivity-score compute-reflexivity-score self
      set RRI-score compute-RRI-score self
      set capability-match-score compute-capability-match-score self
      set expertise-level-score compute-expertise-level-score self
      set SCI-score compute-SCI-score self
    ]
    ; 1st hard factor - SCI score
    if ([SCI-score] of the-proposal < [instr-SCI-min] of the-instrument)
      [ report false ]
    ; 2nd hard factor - RRI score
    if ([RRI-score] of the-proposal < [instr-RRI-min] of the-instrument)
      [ report false ]
    ; OK for all factors
    report true
  ]
end


;observer procedure
to-report capability-match [the-proposal]
  let the-call table:get calls-dict [proposal-call] of the-proposal
  report length remove-duplicates intersection [proposal-capabilities] of the-proposal [call-capabilities] of the-call
end


; In INFSO-SKIN, the decision when to submit the proposal is based entirely on eligibility criteria.
; Any proposal is immediately submitted once it passes those criteria.

; Consortia might however wish to do more, in order to make their proposal more attractive.
; Having this option in our model creates more diversity in the proposals, which will be reflected
; also in their capability-match scores.

;participant procedure
to-report ready-to-submit? [the-proposal]
  report eligible? the-proposal
  ;report (eligible? the-proposal) and (thematic-match the-proposal > 0.5)
end


; a criterium to illustrate this idea

;observer procedure
to-report thematic-match [the-proposal]
  let the-call table:get calls-dict [proposal-call] of the-proposal
  let l1 length remove-duplicates intersection
    map [1 + int (? / 100)] [call-capabilities] of the-call
    map [1 + int (? / 100)] [proposal-capabilities] of the-proposal
  let l2 length remove-duplicates
    map [1 + int (? / 100)] [call-capabilities] of the-call
  if l2 = 0
    [ show "Invalid thematic-match score"  report 0 ]
  report 100 * min (list 1 (l1 / l2))
end


;;; RRI SCORE
;;;

; RRI score is the average of the anticipation, participation, reflexivity and responsiveness scores

;observer procedure
to-report compute-RRI-score [the-proposal-or-project]
  let score [anticipation-score] of the-proposal-or-project +
            [participation-score] of the-proposal-or-project +
            [reflexivity-score] of the-proposal-or-project
  ifelse (is-proposal? the-proposal-or-project)
    [ report score / 3 ]  ; no responsiveness score for proposals
    [ report (score + [responsiveness-score] of the-proposal-or-project) / 4 ]
end


; anticipation score is the ratio of
;   1) the number of unique special capabilities listed in the proposal, to
;   2) the number of unique special capabilities asked in the Call

;observer procedure
to-report compute-anticipation-score [the-proposal]
  let the-call table:get calls-dict [proposal-call] of the-proposal
  let l1 length remove-duplicates intersection [proposal-capabilities] of the-proposal special-cap-list
  let l2 length remove-duplicates intersection [call-capabilities] of the-call special-cap-list
  if (l2 = 0)
    [ show "Invalid anticipation score"  report 0 ]
  report 100 * min (list 1 (l1 / l2))
end


; participation score is the ratio of
;   1) the number of CSOs in the proposal's consortium, to
;   2) the number of CSOs asked in the Call

;observer procedure
to-report compute-participation-score [the-proposal]
  let the-instrument table:get instruments-dict [proposal-type] of the-proposal
  let n1 count [proposal-consortium with [my-type = "cso"]] of the-proposal
  let n2 [instr-CSO-min] of the-instrument
  if (n2 = 0)
    [ show "Invalid participation score"  report 0 ]
  report 100 * min (list 1 (n1 / n2))
end


; reflexivity score is the ratio of
;   1) the number of unique non-special capabilities listed in the proposal, to
;   2) the number of unique non-special capabilities asked in the Call

;observer procedure
to-report compute-reflexivity-score [the-proposal]
  let the-call table:get calls-dict [proposal-call] of the-proposal
  let l1 length remove-duplicates [proposal-capabilities] of the-proposal
  let l2 length remove-duplicates [call-capabilities] of the-call
  if (l2 = 0)
    [ show "Invalid reflexivity score"  report 0 ]
  report 100 * min (list 1 (l1 / l2))
end


; responsiveness score reflects strategy change

;observer procedure
to-report compute-responsiveness-score [the-project]
  report 0
end


;;; SCI SCORE
;;;

; SCI score is the average of the capability-match and expertise-level scores

;observer procedure
to-report compute-SCI-score [the-proposal-or-project]
  report ([capability-match-score] of the-proposal-or-project +
          [expertise-level-score] of the-proposal-or-project) / 2
end


; capability-match score is the ratio of
;   1) the number of unique non-special matching capabilities in the proposal, to
;   2) the number of unique non-special capabilities asked in the Call

;observer procedure
to-report compute-capability-match-score [the-proposal]
  let the-call table:get calls-dict [proposal-call] of the-proposal
  let l1 length remove-duplicates intersection [proposal-capabilities] of the-proposal [call-capabilities] of the-call
  let l2 length remove-duplicates [call-capabilities] of the-call
  if (l2 = 0)
    [ show "Invalid capability-match score"  report 0 ]
  report 100 * min (list 1 (l1 / l2))
end


; expertise-level score is the ratio of
;   1) the mean level of relevant non-special expertise of the proposal's consortium members, to
;   2) the maximum possible expertise level

;observer procedure
to-report compute-expertise-level-score [the-proposal]
  ifelse (length [proposal-expertises] of the-proposal > 0) [
    let e1 mean [proposal-expertises] of the-proposal
    let e2 10
    report 100 * min (list 1 (e1 / e2))
  ] [ show "Invalid expertise-level score"  report 0 ]
end


; All proposals which fulfil the eligibility criteria are than ranked according to the following rule:
; The first ranking order is the average expertise level of the proposals (i.e. the expertise levels of
; the capabilities are summed up and divided by the number of quadruples in the proposal).
; If some proposals turn out to have the same average expertise level, the second criteria applied is
; the number of capabilities specified in the call which are in the proposal (i.e. a proposal is ranked
; higher in the case more outlined capabilities are used).
; If after the application of this rule proposals are still ranked equally, we randomly decide on the
; ranking. As in the call the number x of projects which will be supported by the Commission is
; specified, the Commission chooses the x highest ranked proposals.


;observer procedure
to-report rank [the-eligible-proposals the-funding-available]
  ; 1. give a (unique) ranking-nr to each of the eligible proposals
  ; 2. report the number of proposals that can be funded
  set the-eligible-proposals sort-by [ranking-comparator? ?1 ?2] the-eligible-proposals
  let n 0
  let nr 1
  foreach the-eligible-proposals [
    ask ? [
      set proposal-ranking-nr nr
      let the-instrument table:get instruments-dict proposal-type
      let funding-requested (count proposal-consortium * [instr-duration-avg] of the-instrument * [instr-contribution] of the-instrument) / 1000000
      set the-funding-available the-funding-available - funding-requested
      if the-funding-available >= 0
        [ set n n + 1 ]
      set nr nr + 1
    ]
  ]
  report n
end


; reporter for the ranking the eligible proposals.
; Two proposals are being compared. Reporter should be true if ?1 comes strictly before ?2 in the desired
; sort order, and false otherwise

to-report ranking-comparator? [a-proposal another-proposal]
  let the-instrument table:get instruments-dict [proposal-type] of a-proposal
  let i position [instr-RRI-criteria] of the-instrument ["none" "all"]
  ifelse i = 0 [
    ; RRI/SCI scores are NOT used for ranking
    ; 1st ranking order - average expertise level of the proposals
    ; 2nd ranking order - number of capabilities specified in the call which are in the proposal
    ; 3rd ranking order - randomly decide on the ranking
    if [mean proposal-expertises] of a-proposal > [mean proposal-expertises] of another-proposal [ report true ]
    if [mean proposal-expertises] of a-proposal = [mean proposal-expertises] of another-proposal
      [
        if capability-match a-proposal > capability-match another-proposal [ report true ]
        if capability-match a-proposal = capability-match another-proposal [ report random 2 = 1 ]
      ]
    report false
  ] [
    ; RRI/SCI scores are used
    ; 1st ranking order - total balanced SCI/RRI score of the proposals
    ; 2nd ranking order - randomly decide on the ranking
    if total-score a-proposal > total-score another-proposal [ report true ]
    if total-score a-proposal = total-score another-proposal [ report random 2 = 1 ]
    report false
  ]
end


; compute the total balanced RRI/SCI score

to-report total-score [the-proposal]
  let the-instrument table:get instruments-dict [proposal-type] of the-proposal
  let RRI-balance [instr-RRI-balance] of the-instrument
  report (RRI-balance * [RRI-score] of the-proposal +
         (100 - RRI-balance) * [SCI-score] of the-proposal) / 100
end


;;; COMBINE PROPOSALS
;;;
;;;

; very large projects can be the result of combining two or more proposals into one. This can be done by the Commission
; after the ranking of all eligible proposals

; WARNING: This needs to be fleshed out further.

;call procedure
to combine-proposals
  let accepted-proposal one-of proposals with [proposal-status = "accepted"]
  let rejected-proposal one-of proposals with [proposal-status = "rejected"]
  combine accepted-proposal rejected-proposal
end


;observer procedure
to combine [a-proposal another-proposal]
  ask a-proposal [
    set proposal-consortium (turtle-set proposal-consortium [proposal-consortium] of another-proposal)
    foreach [proposal-capabilities] of another-proposal [ set proposal-capabilities lput ? proposal-capabilities ]
    foreach [proposal-abilities]    of another-proposal [ set proposal-abilities lput ? proposal-abilities ]
    foreach [proposal-expertises]   of another-proposal [ set proposal-expertises lput ? proposal-expertises ]
    foreach [proposal-orientations] of another-proposal [ set proposal-orientations lput ? proposal-orientations ]
    foreach [proposal-contributors] of another-proposal [ set proposal-contributors lput ? proposal-contributors ]
  ]
  ask another-proposal [
    set proposal-status "combined"
  ]
end


;;; DISSOLVE PROPOSALS & MAKE PROJECTS
;;;
;;;


; Proposal consortia which are not successful are dissolved.
; Proposal consortia which are successful become project consortia.

;observer procedure
to dissolve-proposals
  ; successful consortia -> project consortia
  ask proposals with [proposal-status = "accepted"] [ make-project dissolve-proposal ]
  ; dissolve merged consortia
  ask proposals with [proposal-status = "merged"] [ dissolve-proposal ]
  ; dissolve not successful consortia
  ask proposals with [proposal-status = "ineligible"] [ dissolve-proposal ]
  ask proposals with [proposal-status = "rejected"] [ dissolve-proposal ]
end


; make the project based on the proposal

;proposal procedure
to make-project
  let the-proposal self
  let the-consortium proposal-consortium
  let the-instrument table:get instruments-dict proposal-type
  let the-new-project nobody
  hatch-projects 1 [
    set the-new-project self
    ; pass on properties of the proposal to the new project
    set project-nr [proposal-nr] of the-proposal
    set project-type [proposal-type] of the-proposal
    set project-call [proposal-call] of the-proposal
    set project-consortium (turtle-set the-consortium)
    set project-capabilities map [?] [proposal-capabilities] of the-proposal
    set project-abilities map [?] [proposal-abilities] of the-proposal
    set project-expertises map [?] [proposal-expertises] of the-proposal
    set project-orientations map [?] [proposal-orientations] of the-proposal
    set project-contributors map [?] [proposal-contributors] of the-proposal
    ; project starts x months after the call closed
    set project-start-date ticks + round random-normal time-before-project-start 3
    ; project end date depends on the project type
    ; duration is drawn from normal distristibution
    set project-end-date project-start-date + round random-normal [instr-duration-avg] of the-instrument [instr-duration-stdev] of the-instrument
    ; EC contribution depends on the project type and size
    set project-contribution count project-consortium * [instr-duration-avg] of the-instrument * [instr-contribution] of the-instrument
    set project-subprojects no-turtles
    set project-status ""
    set anticipation-score [anticipation-score] of the-proposal
    set participation-score [participation-score] of the-proposal
    set reflexivity-score [reflexivity-score] of the-proposal
    set responsiveness-score 0  ; needs to be computed
    set capability-match-score [capability-match-score] of the-proposal
    set expertise-level-score [expertise-level-score] of the-proposal
    set RRI-score 0  ; needs to be computed
    set SCI-score [SCI-score] of the-proposal
    set project-successful? false
    set project-kf 0
    set project-kf-CSO 0
  ]

  if not Empirical-case? [
    ; allocate partners to sub-projects
    ask the-new-project [ allocate-to-subprojects ]
    ask [project-subprojects] of the-new-project [ make-deliverable ]
  ]

  if log? [ print (word "New project " [project-nr] of the-new-project " of type " [project-type] of the-new-project ".") ]
end


;proposal procedure
to dissolve-proposal
  let the-proposal self

  ; update agents
  ask proposal-consortium [
    ; remove the proposal from my proposals list
    set my-proposals (my-proposals with [self != the-proposal])
    ; update proposal participation list
    if [proposal-status] of the-proposal != "stopped" [
      set participation-in-proposals lput ([proposal-nr] of the-proposal) participation-in-proposals
    ]
  ]

  ; update proposal measures
  if proposal-status != "stopped" [
    set proposals-count proposals-count + 1
    if count proposal-consortium with [my-type = "sme"] > 0
      [ set proposals-with-SME-count proposals-with-SME-count + 1 ]
    if count proposal-consortium with [my-type = "cso"] > 0
      [ set proposals-with-CSO-count proposals-with-CSO-count + 1 ]
    set proposals-type lput proposal-type proposals-type
    set proposals-call lput proposal-call proposals-call
    set proposals-size lput (count proposal-consortium) proposals-size
    set proposals-RES lput (count proposal-consortium with [my-type = "res"]) proposals-RES
    set proposals-DFI lput (count proposal-consortium with [my-type = "dfi"]) proposals-DFI
    set proposals-SME lput (count proposal-consortium with [my-type = "sme"]) proposals-SME
    set proposals-CSO lput (count proposal-consortium with [my-type = "cso"]) proposals-CSO
    set proposals-anticipation lput ([anticipation-score] of the-proposal) proposals-anticipation
    set proposals-participation lput ([participation-score] of the-proposal) proposals-participation
    set proposals-reflexivity lput ([reflexivity-score] of the-proposal) proposals-reflexivity
    set proposals-capability-match lput ([capability-match-score] of the-proposal) proposals-capability-match
    set proposals-expertise-level lput ([expertise-level-score] of the-proposal) proposals-expertise-level
    set proposals-RRI lput ([RRI-score] of the-proposal) proposals-RRI
    set proposals-SCI lput ([SCI-score] of the-proposal) proposals-SCI

    ;;;
    set proposals-size-Super lput (length remove-duplicates [my-snr] of proposal-consortium) proposals-size-Super
    set proposals-RES-Super lput (length remove-duplicates [my-snr] of proposal-consortium with [my-type = "res"]) proposals-RES-Super
    set proposals-DFI-Super lput (length remove-duplicates [my-snr] of proposal-consortium with [my-type = "dfi"]) proposals-DFI-Super
    set proposals-SME-Super lput (length remove-duplicates [my-snr] of proposal-consortium with [my-type = "sme"]) proposals-SME-Super
    set proposals-CSO-Super lput (length remove-duplicates [my-snr] of proposal-consortium with [my-type = "cso"]) proposals-CSO-Super
  ]

  die
end


;;; RESEARCH PROJECTS & DELIVERABLES
;;;
;;; start projects, do research, make deliverables


; every 3 months:
;   Make new deliverable
;   Map artefact: deliverable -> publication or patent
;   Improve results?
;
; every month:
;   Do incremental research
;   Adjust expertises
;   Learn from partners


;project procedure
to start-project
  if project-start-date = ticks [
    set project-status "started"
    if not Empirical-case?
      [ ask project-subprojects [ set subproject-status "started" ] ]
    if log? [ print (word "Project " project-nr " has now started.") ]

    let the-project self
    let the-consortium project-consortium

    ; update the partners
    ask the-consortium [
      set my-projects (turtle-set my-projects the-project)
      set my-partners (turtle-set my-partners (the-consortium with [self != myself]))
    ]
  ]
end


;project procedure
to finish-project
  if project-end-date = ticks [
    set project-status "completed"
    if not Empirical-case?
      [ ask project-subprojects [ set subproject-status "completed" ] ]
  ]
end


; The research in the projects follows the ideas of SKEIN. Agents in project consortia are randomly
; allocated to sub-projects and combine their kenes. Every three months they produce an output (deliverable)
; which can be a working paper, a journal article or a patent. During the length of the project they can
; improve their results.
;
; The research undertaken in projects is incremental research (abilities are substituted, expertise
; levels are increased). The potential of a radical innovation is determined only when the proposal is put
; together in the sense that new capability combinations can appear in consortia. SMEs are important
; candidates for contributing new capabilities and therefore increase the likelihood for
; radical innovation.


; randomly allocate partners to sub-projects and combine their kenes.

;project procedure
to allocate-to-subprojects
  let the-instrument table:get instruments-dict project-type
  let partners [self] of project-consortium
  ifelse length partners < 2 * [instr-sub-size-min] of the-instrument [
    ; small consortium - only 1 sub-project
    make-subprojects 1
    ; add all partners to the 1 sub-project
    foreach partners [
      let the-subproject one-of project-subprojects
      ask ? [ commit-to the-subproject ]
    ]
  ] [
    ; more than 1 sub-project
    make-subprojects min list [instr-sub-nr-max] of the-instrument int ((length partners) / [instr-sub-size-min] of the-instrument)
    ; add randomly the minimal number of partners per sub-project
    ask project-subprojects [
      foreach n-of [instr-sub-size-min] of the-instrument partners [
        ask ? [ commit-to myself ]
        set partners remove ? partners
      ]
    ]
    ; add randomly the remaining partners to sub-projects
    foreach partners [
      let the-subproject one-of project-subprojects
      ask ? [ commit-to the-subproject ]
    ]
  ]
end


;project procedure
to make-subprojects [the-number-of-subprojects]
  set project-subprojects no-turtles
  ; create the number of sub-projects
  let the-project self
  let the-new-subproject nobody
  let nr 1
  repeat the-number-of-subprojects [
    hatch-subprojects 1 [
      set the-new-subproject self
      set subproject-nr nr
      set subproject-project the-project
      set subproject-deliverable []
      set subproject-partners no-turtles
      set subproject-status ""
      set subproject-outputs 0
      set incr-research-direction "random"
      set subproject-capabilities []
      set subproject-abilities []
      set subproject-expertises []
      set subproject-orientations []
      set subproject-contributors []
      set nr nr + 1
    ]
    set project-subprojects (turtle-set project-subprojects the-new-subproject)
  ]
end


; participant procedure
to commit-to [the-subproject]
  let my-number my-nr
  let the-project [subproject-project] of the-subproject
  ; commit to the sub-project
  ask the-subproject [
    ; participant becomes partner of the sub-project
    set subproject-partners (turtle-set subproject-partners myself)
    ; commit the kene quadruples contributed to the project in the proposal stage
    let i 0
    foreach [project-contributors] of the-project [
      if ? = my-number [
        set subproject-capabilities lput (item i [project-capabilities] of the-project) subproject-capabilities
        set subproject-abilities lput (item i [project-abilities] of the-project) subproject-abilities
        set subproject-expertises lput (item i [project-expertises] of the-project) subproject-expertises
        set subproject-orientations lput (item i [project-orientations] of the-project) subproject-orientations
        set subproject-contributors lput my-number subproject-contributors
      ]
      set i i + 1
    ]
  ]
end


; every three months the sub-projects produce an output (deliverable).
; This can be a journal article or a patent

;project procedure
to make-deliverables
  if project-status = "started" [
    ; the time elapsed since the project was started
    let time-elapsed ticks - project-start-date
    if (time-elapsed > 0) and (time-elapsed mod time-between-deliverables = 0) [
      ask project-subprojects with [subproject-status = "started"] [
        ; produce an output (journal article or patent)
        produce-output
        ; improve or change the deliverable
        make-deliverable
      ]
    ]
  ]
end


;subproject procedure
to produce-output
  if subproject-status = "started" [
    set subproject-outputs subproject-outputs + 1
  ]
end


; a deliverable is a vector of locations in the sub-project's kene. So, for example, a deliverable
; might be [1 3 4 7], meaning the second (counting from 0 as the first), fourth, fifth and eighth
; quadruple in the kene. The deliverable cannot be longer than the length of the kene, nor shorter
; than 2, but is of random length between these limits.

;subproject procedure
to make-deliverable
  set subproject-deliverable []
  let location 0
  let kene-length length subproject-capabilities
  let deliverable-length random-between 2 (min (list kene-length max-deliverable-length) + 1)
  while [deliverable-length > 0] [
    set location random kene-length
    if not member? location subproject-deliverable [
      set subproject-deliverable lput location subproject-deliverable
      set deliverable-length deliverable-length - 1
    ]
  ]
  ; reorder the elements of the deliverable in numeric ascending order
  set subproject-deliverable sort subproject-deliverable

  ; initialise incremental research values, since this is a new deliverable, and
  ; previous research will have been using a different deliverable
  set incr-research-direction "random"
end


; reports a random integer greater than or equal to the low-number,
; but stricly less than the high-number

to-report random-between [ low-number high-number ]
  report low-number + random (high-number - low-number)
end


;project procedure
to do-research
  if project-status = "started" [
    ask project-subprojects with [subproject-status = "started"]
      [ do-incremental-research ]
  ]
end


; do incremental research (abilities are substituted)

;subproject procedure
to do-incremental-research
  if subproject-status = "started" [
    if incr-research-direction = "random" [
      let location random length subproject-deliverable
      set ability-to-research item location subproject-deliverable
      ifelse (random 2) = 1
        [ set incr-research-direction "up" ]
        [ set incr-research-direction "down" ]
    ]
    let new-ability item ability-to-research subproject-abilities
    ; TO DO step size is not optimal (see Excel sheet)
    ifelse incr-research-direction = "up"
      [ set new-ability new-ability + (new-ability / item ability-to-research subproject-capabilities) ]
      [ set new-ability new-ability - (new-ability / item ability-to-research subproject-capabilities) ]
    if new-ability <= 0 [ set new-ability 0  set incr-research-direction "random" ]
    if new-ability > 10 [ set new-ability 10 set incr-research-direction "random" ]
    set subproject-abilities replace-item ability-to-research subproject-abilities new-ability
  ]
end


; Raise the expertise level by one (up to a maximum of 10) for capabilities that are used (in my-used-capabilities).
; Decrease the expertise level by one for capabilities that are not used (in my-capabilities but not in my-used-capabilities).
; If an expertise level has dropped to zero, the capability is forgotten, but only if the capability is not contributed
; to any project (not in my-contributed-capabilities).


to adjust-expertise-levels
  let n floor (adjust-expertise-rate * (count participants))
  ask n-of n participants [ adjust-expertise ]
end


;participant procedure
to adjust-expertise
  let my-number my-nr
  let my-contributed-capabilities []
  let my-used-capabilities []

  ; list all my contributed and used capabilities
  ask subprojects [
    let i 0
    foreach subproject-contributors [
      if ? = my-number [
        let contributed-capability item i subproject-capabilities
        ; for contributed-capabilites we consider also the projects that have not started yet
        set my-contributed-capabilities lput contributed-capability my-contributed-capabilities
        ; for used-capabilities we consider only the projects that have already started
        if (subproject-status = "started") and (member? i subproject-deliverable) [
          set my-used-capabilities lput contributed-capability my-used-capabilities
        ]
      ]
      set i i + 1
    ]
  ]
  set my-contributed-capabilities remove-duplicates sort my-contributed-capabilities
  set my-used-capabilities remove-duplicates sort my-used-capabilities

  ; adjust my expertise levels
  let location 0
  while [location < length my-capabilities] [
    let capability item location my-capabilities
    let expertise item location my-expertises
    ifelse member? capability my-used-capabilities [
      ; capability has been used - increase expertise if possible
      if expertise < 10
        [ set my-expertises replace-item location my-expertises (expertise + 1) ]
    ] [
      ; capability has not been used - decrease expertise and drop capability if expertise
      ; has fallen to zero, but only if capability is not contributed to any project
      ifelse expertise > 0 [
        set my-expertises replace-item location my-expertises (expertise - 1)
      ] [
        if not member? capability my-contributed-capabilities [
          forget-capability location
          set location location - 1
        ]
      ]
    ]
    set location location + 1
  ]

  ; update the expertise levels of all projects that the participant is or will be contributor of.
  ; There are two effects:
  ; 1. an immediate effect on the expertise in these projects, which will benefit from the contributor's
  ;    gained expertise or suffer from its lost expertise.
  ; 2. a later effect on the expertise levels that the contributor will add to new proposals

  ;let my-self self
  ;ask subprojects [
  ;  ; this also updates the sub-projects that have not started yet!
  ;  let i 0
  ;  while [i < length subproject-capabilities] [
  ;    let contributor-nr item i subproject-contributors
  ;    if contributor-nr = my-number [
  ;      let contributed-capability item i subproject-capabilities
  ;      set location position contributed-capability [my-capabilities] of my-self
  ;      set subproject-expertises replace-item i subproject-expertises (item location [my-expertises] of my-self)
  ;    ]
  ;    set i i + 1
  ;  ]
  ;]
end


; remove the capability, ability, expertise at the given location of the kene.
; The capability that is being forgotten is not included in a project's deliverable.
; Although the kene is changed, the deliverable and the output are not (since
; the forgotten capability is not in the deliverable, this doesn't matter)

;participant procedure
to forget-capability [location]
  set my-capabilities remove-item location my-capabilities
  set my-abilities remove-item location my-abilities
  set my-expertises remove-item location my-expertises
  set my-orientations remove-item location my-orientations
end


; obtain capabilities from partners.
; The capabilities that are learned are those from the subproject's deliverable

;project procedure
to learn-from-partners
  if project-status = "started" [
    ask project-subprojects with [subproject-status = "started"]
      [ learn-from-subproject-partners ]
  ]

  ; TO DO:
  ; for test only, we update the knowledge flow during the project
  ; needs proper bookkeeping code
  ;set project-kf project-kf + 5
  ;set project-kf-CSO project-kf-CSO + 1
  ;set project-responsiveness 100 * project-kf-CSO / project-kf
end


;subproject procedure
to learn-from-subproject-partners
  if subproject-status = "started" [
    ask subproject-partners [ add-capabilities myself ]
  ]
end


; for each capability in the deliverable, if it is new to me,
; add it (and its ability) to my kene (if I have sufficient capacity), and make
; the expertise level 1 less. For each capability that is not new, if the sub-project's
; expertise level is greater than mine, adopt its ability and expertise level,
; otherwise do nothing

; TO DO: The intensity of learning is implicitly assumed by letting partners learn every tick. It would be
; better to make this assumption explicit and provide a slider for changing the intensity.

;participant procedure
to add-capabilities [the-subproject]
  ; measure the agent's knowledge before
  let my-knowledge-before length my-capabilities

  let new-capability? false
  let contributor-nr 0

  let location 0
  foreach [subproject-deliverable] of the-subproject [
    let capability item ? [subproject-capabilities] of the-subproject

    set new-capability? false
    set contributor-nr 0

    ifelse member? capability my-capabilities [
      ; capability already known to me
      set location position capability my-capabilities
      if item location my-expertises < item ? [subproject-expertises] of the-subproject [
        set my-expertises replace-item location my-expertises (item ? [subproject-expertises] of the-subproject)
        set my-abilities replace-item location my-abilities (item ? [subproject-abilities] of the-subproject)
      ]
    ] [
      ; capability is new to me; adopt it if I have 'room'
      if length my-capabilities < my-cap-capacity [
        set my-capabilities lput capability my-capabilities
        set my-abilities lput (item ? [subproject-abilities] of the-subproject) my-abilities
        let other-expertise (item ? [subproject-expertises] of the-subproject) - 1
        ; if other-expertise is 1, it is immediately forgotten by adjust-expertise
        if other-expertise < 2 [ set other-expertise 2 ]
        set my-expertises lput other-expertise my-expertises
        set my-orientations lput (item ? [subproject-orientations] of the-subproject) my-orientations

        ; record the knowledge flow
        set new-capability? true
        set contributor-nr (item ? [subproject-contributors] of the-subproject)
      ]
    ]

    if new-capability? [
      let contributor table:get participants-dict contributor-nr
      if [my-type] of contributor = "res" [
        if my-type = "res" [ set kf-RES-to-RES kf-RES-to-RES + 1 ]
        if my-type = "dfi" [ set kf-RES-to-DFI kf-RES-to-DFI + 1 ]
        if my-type = "sme" [ set kf-RES-to-SME kf-RES-to-SME + 1 ]
        if my-type = "cso" [ set kf-RES-to-CSO kf-RES-to-CSO + 1 ]
      ]
      if [my-type] of contributor = "dfi" [
        if my-type = "res" [ set kf-DFI-to-RES kf-DFI-to-RES + 1 ]
        if my-type = "dfi" [ set kf-DFI-to-DFI kf-DFI-to-DFI + 1 ]
        if my-type = "sme" [ set kf-DFI-to-SME kf-DFI-to-SME + 1 ]
        if my-type = "cso" [ set kf-DFI-to-CSO kf-DFI-to-CSO + 1 ]
      ]
      if [my-type] of contributor = "sme" [
        if my-type = "res" [ set kf-SME-to-RES kf-SME-to-RES + 1 ]
        if my-type = "dfi" [ set kf-SME-to-DFI kf-SME-to-DFI + 1 ]
        if my-type = "sme" [ set kf-SME-to-SME kf-SME-to-SME + 1 ]
        if my-type = "cso" [ set kf-SME-to-CSO kf-SME-to-CSO + 1 ]
      ]
      if [my-type] of contributor = "cso" [
        if my-type = "res" [ set kf-CSO-to-RES kf-CSO-to-RES + 1 ]
        if my-type = "dfi" [ set kf-CSO-to-DFI kf-CSO-to-DFI + 1 ]
        if my-type = "sme" [ set kf-CSO-to-SME kf-CSO-to-SME + 1 ]
        if my-type = "cso" [ set kf-CSO-to-CSO kf-CSO-to-CSO + 1 ]
      ]
    ]
  ]

  ; measure the agent's knowledge after
  let my-knowledge-after length my-capabilities
  set knowledge-flow knowledge-flow + my-knowledge-after - my-knowledge-before
end


; the expertise levels of the capabilities used for the deliverables are increasing at each iteration.
; Capabilities of deliverables are exchanged among partners (i.e. knowledge transfer in projects, but
; they have to start with low expertise).


;;; EVALUATION OF PROJECTS
;;;
;;; evaluate completed projects


;observer procedure
to evaluate-projects
  ; look at all completed projects - what was their responsiveness?
  ask projects with [project-status = "completed"] [
    ; compute the responsiveness score of the project
    set responsiveness-score compute-responsiveness-score self
    set RRI-score compute-RRI-score self
  ]
  ; TO DO what are the consequences of a positive/negative evaluation?
end


;;; DISSOLVE PROJECTS
;;;
;;;


; at the end of the project all results are delivered to the Commission. And the partners start new
; proposal consortia etc. Only in the case the results are below a certain threshold the Commission puts
; the partners of the project on a black list. However, so far we have not considered to implement any
; consequences from this.

;observer procedure
to dissolve-projects
  ask projects with [project-status = "completed"] [ dissolve-project ]
end


;project procedure
to dissolve-project
  let the-project self
  let the-consortium project-consortium
  let n count participants

  ; update partners
  ask the-consortium [
    ; remove the project from my projects list
    set my-projects my-projects with [self != the-project]
    ; add the consortium partners to my list of previous partners
    set my-previous-partners (turtle-set my-previous-partners (the-consortium with [self != myself]))
    ; update history of partnerships
    let mynr my-nr
    foreach [self] of the-consortium with [my-nr > mynr] [
      let index ((mynr - 1) * n) + [my-nr] of ? - 1
      array:set partnerships-matrix index (array:item partnerships-matrix index) + 1
    ]
    ; update project participation list
    set participation-in-projects lput ([project-nr] of the-project) participation-in-projects
    ; rebuild my list of partners
    rebuild-partners-list
  ]
  ;;;
  let the-consortium-snr sort remove-duplicates [my-snr] of the-consortium
  foreach the-consortium-snr [
    let mysnr ?
    foreach filter [? > mysnr] the-consortium-snr [
      let index ((mysnr - 1) * n) + ? - 1
      array:set partnerships-matrix-Super index (array:item partnerships-matrix-Super index) + 1
    ]
  ]

  ; update project measures
  set projects-count projects-count + 1
  if count the-consortium with [my-type = "sme"] > 0
    [ set projects-with-SME-count projects-with-SME-count + 1 ]
  if count the-consortium with [my-type = "cso"] > 0
    [ set projects-with-CSO-count projects-with-CSO-count + 1 ]
  set projects-type lput project-type projects-type
  set projects-call lput project-call projects-call
  set projects-size lput (count the-consortium) projects-size
  set projects-RES lput (count the-consortium with [my-type = "res"]) projects-RES
  set projects-DFI lput (count the-consortium with [my-type = "dfi"]) projects-DFI
  set projects-SME lput (count the-consortium with [my-type = "sme"]) projects-SME
  set projects-CSO lput (count the-consortium with [my-type = "cso"]) projects-CSO
  set projects-duration lput (project-end-date - project-start-date) projects-duration
  set projects-contribution lput (project-contribution / 1000000) projects-contribution
  set projects-anticipation lput ([anticipation-score] of the-project) projects-anticipation
  set projects-participation lput ([participation-score] of the-project) projects-participation
  set projects-reflexivity lput ([reflexivity-score] of the-project) projects-reflexivity
  set projects-responsiveness lput ([responsiveness-score] of the-project) projects-responsiveness
  set projects-RRI lput ([RRI-score] of the-project) projects-RRI
  set projects-capability-match lput ([capability-match-score] of the-project) projects-capability-match
  set projects-expertise-level lput ([expertise-level-score] of the-project) projects-expertise-level
  set projects-SCI lput ([SCI-score] of the-project) projects-SCI
  ;;;
  set projects-size-Super lput (length remove-duplicates [my-snr] of the-consortium) projects-size-Super
  set projects-RES-Super lput (length remove-duplicates [my-snr] of the-consortium with [my-type = "res"]) projects-RES-Super
  set projects-DFI-Super lput (length remove-duplicates [my-snr] of the-consortium with [my-type = "dfi"]) projects-DFI-Super
  set projects-SME-Super lput (length remove-duplicates [my-snr] of the-consortium with [my-type = "sme"]) projects-SME-Super
  set projects-CSO-Super lput (length remove-duplicates [my-snr] of the-consortium with [my-type = "cso"]) projects-CSO-Super

  ; the project and its sub-projects die
  if not Empirical-case?
    [ ask project-subprojects [ die ] ]
  die
end


; participant procedure
to rebuild-partners-list
  set my-partners no-turtles
  foreach [self] of my-projects with [project-status = "started"] [
    let the-consortium [project-consortium] of ?
    set my-partners (turtle-set my-partners (the-consortium with [self != myself]))
  ]
end


;;; DISPLAY
;;;
;;; display some plots


;observer procedure
to update-the-plots
  if not Empirical-case? [
    set-current-plot "Proposals Submitted"
    plot count proposals with [proposal-type = "CIP" and proposal-status = "submitted"]
  ]

  set-current-plot "Projects Started"
  plot count projects with [project-type = "CIP" and project-status = "started"]

  set-current-plot "Projects Completed"
  set-current-plot-pen "all"
  plot projects-count
  set-current-plot-pen "with CSO"
  plot projects-with-CSO-count

  if not Empirical-case? [
    set-current-plot "Participation in Proposals"
    histogram [length participation-in-proposals] of participants
  ]

  set-current-plot "Participation in Projects"
  histogram [length participation-in-projects] of participants

  set-current-plot "Partners"
  histogram [count my-network] of participants with [any? my-network]

  if not Empirical-case? [
    set-current-plot "Proposals Size"
    histogram proposals-size
  ]

  set-current-plot "Projects Size"
  histogram projects-size

  let max-score 99.999

  if not Empirical-case? [
    set-current-plot "Anticipation (RRI Score)"
    histogram map [min (list max-score ?)] proposals-anticipation

    set-current-plot "Participation (RRI Score)"
    histogram map [min (list max-score ?)] proposals-participation

    set-current-plot "Reflexivity (RRI Score)"
    histogram map [min (list max-score ?)] proposals-reflexivity
  ]

  ;set-current-plot "Responsiveness (RRI Score)"
  ;histogram map [min (list max-score ?)] projects-responsiveness

  ;if not Empirical-case?
  ;  [ if length proposals-size > 0 [ plot-degree-distribution "proposals" ] ]
  ;if length projects-size > 0 [ plot-degree-distribution "projects" ]

  if not Empirical-case? [
    set-current-plot "Expertise Level (SCI Score)"
    histogram map [min (list max-score ?)] proposals-expertise-level

    set-current-plot "Capability Match (SCI Score)"
    histogram map [min (list max-score ?)] proposals-capability-match
  ]

  set-current-plot "Total RRI Score"
  histogram map [min (list max-score ?)] projects-RRI

  set-current-plot "Total SCI Score"
  histogram map [min (list max-score ?)] projects-SCI

  ;set-current-plot "Network Density"
  ;plot density

  ;set-current-plot "Number of Components"
  ;plot number-of-components

  ;set-current-plot "Size of Largest Component"
  ;plot largest-component-size

  ;set-current-plot "Average Degree"
  ;plot average-degree

  ;set-current-plot "Average Path Length"
  ;plot average-path-length

  ;set-current-plot "Clustering"
  ;plot clustering-coefficient

  if not Empirical-case? [
    set-current-plot "Knowledge Space"
    histogram (sentence capabilities-RES capabilities-DFI capabilities-SME capabilities-CSO)

    set-current-plot "Knowledge"
    plot knowledge

    set-current-plot "Knowledge (Distribution)"
    histogram (sentence kenes-length-RES kenes-length-DFI kenes-length-SME kenes-length-CSO)

    set-current-plot "Knowledge Flow"
    plot knowledge-flow

    set-current-plot "Knowledge Flow (Detail)"
    set-current-plot-pen "with CSO"
    plot kf-CSO-to-RES + kf-CSO-to-DFI + kf-CSO-to-SME + kf-CSO-to-CSO
  ]
end


; plot log(number of participants) by log(frequency of projects with that number of participants)
; at the present moment of time, plus a regression line

to plot-degree-distribution [the-type-of-networks]
  if the-type-of-networks = "proposals" [ set-current-plot "Proposals Size (Regression)" ]
  if the-type-of-networks = "projects" [ set-current-plot "Projects Size (Regression)" ]
  clear-plot ; erase what we plotted before
  set-plot-pen-color black
  set-plot-pen-mode 2 ; plot points
  let max-degree 0
  if the-type-of-networks = "proposals" [ set max-degree max proposals-size ]
  if the-type-of-networks = "projects" [ set max-degree max projects-size ]
  let degree 1 ; only include nodes with at least one link
  let sumx 0 ; for regression line
  let sumy 0
  let sumxy 0
  let sumxx 0
  let sumyy 0
  let n 0
  while [degree <= max-degree] [
    let matches 0
    if the-type-of-networks = "proposals" [ set matches filter [? = degree] proposals-size ]
    if the-type-of-networks = "projects" [ set matches filter [? = degree] projects-size ]
    if length matches > 0 [
      let x log degree 10
      let y log (length matches) 10
      plotxy x y
      set sumx sumx + x
      set sumy sumy + y
      set sumxy sumxy + x * y
      set sumxx sumxx + x * x
      set sumyy sumyy + y * y
      set n n + 1
    ]
    set degree degree + 1
  ]
  if n > 1 [
   let slope  (n * sumxy - sumx * sumy) / (n * sumxx - sumx * sumx)
   let intercept  (sumy - slope * sumx) / n
   create-temporary-plot-pen "regression line"
   set-plot-pen-mode 0
   set-plot-pen-color red
   plot-pen-up
   plotxy 0 intercept
   plot-pen-down
   ifelse slope = 0
     [ plotxy intercept intercept ] ; regression line is parallel to x-axis
     [ plotxy -1 * intercept / slope 0 ]
  ]
end


;;; MONITORS
;;;
;;; monitor some outputs


;observer procedure
to-report show-call-status [the-call-nr]
  let the-call one-of calls with [call-nr = the-call-nr]
  report [call-status] of the-call
end


;observer procedure
to-report show-call-counter [the-proposal-status]
  report [table:get call-counter the-proposal-status] of the-current-call
end


;;; NETWORK MEASURES
;;;
;;; density, number of components, etc.


;observer procedure
to update-network-measures
  set participants-in-net participants with [any? my-network]
  count-all-edges
  find-all-components
  if compute-network-distances? [
    ; computationally expensive!
    set connected? true
    find-path-lengths
    set diameter max [max remove infinity distance-from-other-participants] of participants-in-net
    set num-connected-pairs sum [length remove infinity (remove 0 distance-from-other-participants)] of participants-in-net
    if num-connected-pairs != (count participants-in-net * (count participants-in-net - 1))
      [ set connected? false ]
    ifelse num-connected-pairs > 0
      [ set average-path-length (sum [sum remove infinity distance-from-other-participants] of participants-in-net) / (num-connected-pairs) ]
      [ set average-path-length infinity ]
  ]
  find-clustering-coefficient
end


; use the which-network variable to define what is the collaborations network
; (all the network measures and exported files will be different).
; The default option is "current and previous partners"

; participant procedure
to-report my-network
  if which-network = "partners" [ report my-partners ]
  if which-network = "previous partners" [ report my-previous-partners ]
  ; default: report my current and previous research partners
  report (turtle-set my-partners my-previous-partners)
end


; observer procedure
to count-all-edges
  set count-of-edges 0
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants-in-net
  ; edges
  foreach participants-list [
    let mynr [my-nr] of ?
    ask ? [
      foreach filter [[my-nr] of ? > mynr] participants-list [
        if member? ? my-network
          [ set count-of-edges count-of-edges + 1]
      ]
    ]
  ]
  ; possible edges
  set count-of-possible-edges count participants-in-net * (count participants-in-net - 1) / 2
  ifelse any? participants-in-net [
    ; density
    set density count-of-edges / count-of-possible-edges
    ; average degree
    set average-degree 2 * count-of-edges / count participants-in-net
  ] [
    set density 99999
    set average-degree 99999
  ]
end


; to find all the connected components in the network, their sizes and starting nodes

; observer procedure
to find-all-components
  set number-of-components 0
  set largest-component-size 0
  ask participants-in-net [ set explored? false ]
  loop
  [
    let start one-of participants-in-net with [ not explored? ]
    if start = nobody [ stop ]
    set number-of-components number-of-components + 1
    set component-size 0
    ask start [ explore ]
    if component-size > largest-component-size
    [
      set largest-component-size component-size
      set largest-start-node start
    ]
  ]
end


; finds all participants reachable from this node

; participant procedure
to explore
  if explored? [ stop ]
  set explored? true
  set component-size component-size + 1
  ask my-network [ explore ]
end


to-report in-neighborhood? [ hood ]
  report (member? end1 hood and member? end2 hood)
end


to find-clustering-coefficient
  ifelse any? participants-in-net [
    ask participants-in-net [
      ask my-network
        [ create-link-with myself]
    ]
    ifelse all? participants-in-net [count my-network <= 1] [
      set clustering-coefficient 0
    ] [
      let total 0
      ask participants-in-net with [count my-network <= 1]
        [ set node-clustering-coefficient 0 ]
      ask participants-in-net with [count my-network > 1]
        [
          let hood link-neighbors
          set node-clustering-coefficient (2 * count links with [in-neighborhood? hood] / (count hood * (count hood - 1)))
          set total total + node-clustering-coefficient
        ]
      ;set clustering-coefficient total / count participants-in-net with [count link-neighbors > 1]
      set clustering-coefficient total / count participants-in-net
    ]
    clear-links
  ] [
    set clustering-coefficient 99999
  ]
end


to find-path-lengths
  ask participants-in-net [ set distance-from-other-participants [] ]
  let i 0
  let j 0
  let k 0
  let node1 one-of participants-in-net
  let node2 one-of participants-in-net
  let node-count count participants-in-net
  while [i < node-count] [
    set j 0
    while [j < node-count] [
      set node1 turtle i
      set node2 turtle j
      ifelse i = j
        [ ask node1 [ set distance-from-other-participants lput 0 distance-from-other-participants ] ]
        [
          ifelse member? node1 [my-network] of node2
            [ ask node1 [ set distance-from-other-participants lput 1 distance-from-other-participants ] ]
            [ ask node1 [ set distance-from-other-participants lput infinity distance-from-other-participants ]
        ]
      ]
      set j j + 1
    ]
    set i i + 1
  ]
  set i 0
  set j 0
  let dummy 0
  while [k < node-count] [
    set i 0
    while [i < node-count] [
      set j 0
      while [j < node-count] [
        set dummy (item k [distance-from-other-participants] of turtle i) +
                  (item j [distance-from-other-participants] of turtle k)
        if dummy < (item j [distance-from-other-participants] of turtle i)
          [ ask turtle i [ set distance-from-other-participants replace-item j distance-from-other-participants dummy ] ]
        set j j + 1
      ]
      set i i + 1
    ]
    set k k + 1
  ]
end


;;; KNOWLEDGE MEASURES
;;;
;;; based on length of kenes


;observer procedure
to update-knowledge-measures
  set capabilities-RES []  set capabilities-DFI []  set capabilities-SME []  set capabilities-CSO []
  set kenes-length-RES []  set kenes-length-DFI []  set kenes-length-SME []  set kenes-length-CSO []
  ask participants with [my-type = "res"] [ foreach my-capabilities [ set capabilities-RES lput ? capabilities-RES ] ]
  ask participants with [my-type = "dfi"] [ foreach my-capabilities [ set capabilities-DFI lput ? capabilities-DFI ] ]
  ask participants with [my-type = "sme"] [ foreach my-capabilities [ set capabilities-SME lput ? capabilities-SME ] ]
  ask participants with [my-type = "cso"] [ foreach my-capabilities [ set capabilities-CSO lput ? capabilities-CSO ] ]
  ask participants with [my-type = "res"] [ set kenes-length-RES lput (length my-capabilities) kenes-length-RES ]
  ask participants with [my-type = "dfi"] [ set kenes-length-DFI lput (length my-capabilities) kenes-length-DFI ]
  ask participants with [my-type = "sme"] [ set kenes-length-SME lput (length my-capabilities) kenes-length-SME ]
  ask participants with [my-type = "cso"] [ set kenes-length-CSO lput (length my-capabilities) kenes-length-CSO ]
  set knowledge sum kenes-length-RES + sum kenes-length-DFI + sum kenes-length-SME + sum kenes-length-CSO

  set capabilities-frequency-RES []  set capabilities-frequency-DFI []  set capabilities-frequency-SME []  set capabilities-frequency-CSO []
  let capability 1
  while [capability <= nCapabilities] [
    set capabilities-frequency-RES lput (frequency capability capabilities-RES) capabilities-frequency-RES
    set capabilities-frequency-DFI lput (frequency capability capabilities-DFI) capabilities-frequency-DFI
    set capabilities-frequency-SME lput (frequency capability capabilities-SME) capabilities-frequency-SME
    set capabilities-frequency-CSO lput (frequency capability capabilities-CSO) capabilities-frequency-CSO
    set capability capability + 1
  ]

  set capabilities-diffusion []
  let theme 1
  let capabilities-per-theme nCapabilities / count themes  ; 100
  while [theme <= nThemes] [
    let m 0
    let lowest 1 + (theme - 1) * capabilities-per-theme
    let highest theme * capabilities-per-theme
    ask participants [
      let capabilities-from-theme filter [? >= lowest and ? <= highest] my-capabilities
      if length capabilities-from-theme > 0
        [ set m m + 1 ]
    ]
    let n count participants
    set capabilities-diffusion lput (m / n) capabilities-diffusion
    set theme theme + 1
  ]

  ;;;
  set capabilities-RES-Super []  set capabilities-DFI-Super []  set capabilities-SME-Super []  set capabilities-CSO-Super []
  set kenes-length-RES-Super []  set kenes-length-DFI-Super []  set kenes-length-SME-Super []  set kenes-length-CSO-Super []
  let participants-snr sort remove-duplicates [my-snr] of participants
  foreach participants-snr [
    let capabilities-Super []
    ask participants with [my-snr = ?]
      [ set capabilities-Super (sentence capabilities-Super my-capabilities) ]
    set capabilities-Super remove-duplicates capabilities-Super
    let type-Super ""
    ask one-of participants with [my-snr = ?]
      [ set type-Super my-type ]
    if type-Super = "res" [ set capabilities-RES-Super (sentence capabilities-RES-Super capabilities-Super) ]
    if type-Super = "dfi" [ set capabilities-DFI-Super (sentence capabilities-DFI-Super capabilities-Super) ]
    if type-Super = "sme" [ set capabilities-SME-Super (sentence capabilities-SME-Super capabilities-Super) ]
    if type-Super = "cso" [ set capabilities-CSO-Super (sentence capabilities-CSO-Super capabilities-Super) ]
    if type-Super = "res" [ set kenes-length-RES-Super lput (length capabilities-Super) kenes-length-RES-Super ]
    if type-Super = "dfi" [ set kenes-length-DFI-Super lput (length capabilities-Super) kenes-length-DFI-Super ]
    if type-Super = "sme" [ set kenes-length-SME-Super lput (length capabilities-Super) kenes-length-SME-Super ]
    if type-Super = "cso" [ set kenes-length-CSO-Super lput (length capabilities-Super) kenes-length-CSO-Super ]
  ]

  set capabilities-frequency-RES-Super []  set capabilities-frequency-DFI-Super []  set capabilities-frequency-SME-Super []  set capabilities-frequency-CSO-Super []
  set capability 1
  while [capability <= nCapabilities] [
    set capabilities-frequency-RES-Super lput (frequency capability capabilities-RES-Super) capabilities-frequency-RES-Super
    set capabilities-frequency-DFI-Super lput (frequency capability capabilities-DFI-Super) capabilities-frequency-DFI-Super
    set capabilities-frequency-SME-Super lput (frequency capability capabilities-SME-Super) capabilities-frequency-SME-Super
    set capabilities-frequency-CSO-Super lput (frequency capability capabilities-CSO-Super) capabilities-frequency-CSO-Super
    set capability capability + 1
  ]

  set capabilities-diffusion-Super []
  set theme 1
  while [theme <= nThemes] [
    let m 0
    let lowest 1 + (theme - 1) * capabilities-per-theme
    let highest theme * capabilities-per-theme
    foreach participants-snr [
      let capabilities-Super []
      ask participants with [my-snr = ?]
        [ set capabilities-Super (sentence capabilities-Super my-capabilities) ]
      set capabilities-Super remove-duplicates capabilities-Super
      let capabilities-from-theme filter [? >= lowest and ? <= highest] capabilities-Super
      if length capabilities-from-theme > 0
        [ set m m + 1 ]
    ]
    let n length participants-snr
    set capabilities-diffusion-Super lput (m / n) capabilities-diffusion-Super
    set theme theme + 1
  ]
end


to-report frequency[val vallist]
  report length filter [? = val] vallist
end


;;; RUN DATA
;;;
;;; update lists for export-run-data

to update-run-data
  set run-data-participants-RES lput (count participants with [(my-type = "res")]) run-data-participants-RES
  set run-data-participants-RES-net lput (count participants with [(my-type = "res") and (any? my-previous-partners)]) run-data-participants-RES-net
  set run-data-participants-DFI lput (count participants with [(my-type = "dfi")]) run-data-participants-DFI
  set run-data-participants-DFI-net lput (count participants with [(my-type = "dfi") and (any? my-previous-partners)]) run-data-participants-DFI-net
  set run-data-participants-SME lput (count participants with [(my-type = "sme")]) run-data-participants-SME
  set run-data-participants-SME-net lput (count participants with [(my-type = "sme") and (any? my-previous-partners)]) run-data-participants-SME-net
  set run-data-participants-CSO lput (count participants with [(my-type = "cso")]) run-data-participants-CSO
  set run-data-participants-CSO-net lput (count participants with [(my-type = "cso") and (any? my-previous-partners)]) run-data-participants-CSO-net

  if not Empirical-case? [
    set run-data-proposals-submitted lput (count proposals with [proposal-status = "submitted"]) run-data-proposals-submitted
    set run-data-proposals lput proposals-count run-data-proposals
    set run-data-proposals-with-SME lput proposals-with-SME-count run-data-proposals-with-SME
    set run-data-proposals-with-CSO lput proposals-with-CSO-count run-data-proposals-with-CSO
    set run-data-proposals-small lput (length filter [? < 5] proposals-size) run-data-proposals-small
    set run-data-proposals-big lput (length filter [? > 20] proposals-size) run-data-proposals-big
  ]

  set run-data-projects-started lput (count projects with [project-status = "started"]) run-data-projects-started
  set run-data-projects lput projects-count run-data-projects
  set run-data-projects-with-SME lput projects-with-SME-count run-data-projects-with-SME
  set run-data-projects-with-CSO lput projects-with-CSO-count run-data-projects-with-CSO
  set run-data-projects-small lput (length filter [? < 5] projects-size) run-data-projects-small
  set run-data-projects-big lput (length filter [? > 20] projects-size) run-data-projects-big

  ;set run-data-network-density lput density run-data-network-density
  ;set run-data-network-components lput number-of-components run-data-network-components
  ;set run-data-network-largest-component lput largest-component-size run-data-network-largest-component
  ;set run-data-network-avg-degree lput average-degree run-data-network-avg-degree
  ;set run-data-network-avg-path-length lput average-path-length run-data-network-avg-path-length
  ;set run-data-network-clustering lput clustering-coefficient run-data-network-clustering

  if not Empirical-case? [
    set run-data-knowledge lput knowledge run-data-knowledge
    ;set run-data-knowledge-flow lput knowledge-flow run-data-knowledge-flow
    let kf 0
    set kf kf + kf-RES-to-RES + kf-RES-to-DFI + kf-RES-to-SME + kf-RES-to-CSO
    set kf kf + kf-DFI-to-RES + kf-DFI-to-DFI + kf-DFI-to-SME + kf-DFI-to-CSO
    set kf kf + kf-SME-to-RES + kf-SME-to-DFI + kf-SME-to-SME + kf-SME-to-CSO
    set kf kf + kf-CSO-to-RES + kf-CSO-to-DFI + kf-CSO-to-SME + kf-CSO-to-CSO
    set run-data-knowledge-flow lput kf run-data-knowledge-flow
    set run-data-kf-RES-to-RES lput kf-RES-to-RES run-data-kf-RES-to-RES
    set run-data-kf-RES-to-DFI lput kf-RES-to-DFI run-data-kf-RES-to-DFI
    set run-data-kf-RES-to-SME lput kf-RES-to-SME run-data-kf-RES-to-SME
    set run-data-kf-RES-to-CSO lput kf-RES-to-CSO run-data-kf-RES-to-CSO
    set run-data-kf-DFI-to-RES lput kf-DFI-to-RES run-data-kf-DFI-to-RES
    set run-data-kf-DFI-to-DFI lput kf-DFI-to-DFI run-data-kf-DFI-to-DFI
    set run-data-kf-DFI-to-SME lput kf-DFI-to-SME run-data-kf-DFI-to-SME
    set run-data-kf-DFI-to-CSO lput kf-DFI-to-CSO run-data-kf-DFI-to-CSO
    set run-data-kf-SME-to-RES lput kf-SME-to-RES run-data-kf-SME-to-RES
    set run-data-kf-SME-to-DFI lput kf-SME-to-DFI run-data-kf-SME-to-DFI
    set run-data-kf-SME-to-SME lput kf-SME-to-SME run-data-kf-SME-to-SME
    set run-data-kf-SME-to-CSO lput kf-SME-to-CSO run-data-kf-SME-to-CSO
    set run-data-kf-CSO-to-RES lput kf-CSO-to-RES run-data-kf-CSO-to-RES
    set run-data-kf-CSO-to-DFI lput kf-CSO-to-DFI run-data-kf-CSO-to-DFI
    set run-data-kf-CSO-to-SME lput kf-CSO-to-SME run-data-kf-CSO-to-SME
    set run-data-kf-CSO-to-CSO lput kf-CSO-to-CSO run-data-kf-CSO-to-CSO
    set run-data-knowledge-patents lput patents run-data-knowledge-patents
    set run-data-knowledge-articles lput articles run-data-knowledge-articles

    let capabilities-frequency (map [?1 + ?2 + ?3 + ?4] capabilities-frequency-RES capabilities-frequency-DFI capabilities-frequency-SME capabilities-frequency-CSO)
    set run-data-capabilities lput (length filter [? > 0] capabilities-frequency) run-data-capabilities
    foreach capabilities-diffusion
      [ set run-data-capabilities-diffusion lput ? run-data-capabilities-diffusion ]
  ]

  ;;;

  if super? [
    set run-data-participants-RES-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "res")]) run-data-participants-RES-Super
    set run-data-participants-RES-net-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "res") and (any? my-previous-partners)]) run-data-participants-RES-net-Super
    set run-data-participants-DFI-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "dfi")]) run-data-participants-DFI-Super
    set run-data-participants-DFI-net-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "dfi") and (any? my-previous-partners)]) run-data-participants-DFI-net-Super
    set run-data-participants-SME-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "sme")]) run-data-participants-SME-Super
    set run-data-participants-SME-net-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "sme") and (any? my-previous-partners)]) run-data-participants-SME-net-Super
    set run-data-participants-CSO-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "cso")]) run-data-participants-CSO-Super
    set run-data-participants-CSO-net-Super lput (length remove-duplicates [my-snr] of participants with [(my-type = "cso") and (any? my-previous-partners)]) run-data-participants-CSO-net-Super

    if not Empirical-case? [
      set run-data-proposals-small-Super lput (length filter [? < 5] proposals-size-Super) run-data-proposals-small-Super
      set run-data-proposals-big-Super lput (length filter [? > 20] proposals-size-Super) run-data-proposals-big-Super
    ]

    set run-data-projects-small-Super lput (length filter [? < 5] projects-size-Super) run-data-projects-small-Super
    set run-data-projects-big-Super lput (length filter [? > 20] projects-size-Super) run-data-projects-big-Super

    ;run-data-network-density-Super
    ;run-data-network-components-Super
    ;run-data-network-largest-component-Super
    ;run-data-network-avg-degree-Super
    ;run-data-network-avg-path-length-Super
    ;run-data-network-clustering-Super

    if not Empirical-case? [
      let capabilities-frequency-Super (map [?1 + ?2 + ?3 + ?4] capabilities-frequency-RES-Super capabilities-frequency-DFI-Super capabilities-frequency-SME-Super capabilities-frequency-CSO-Super)
      set run-data-capabilities-Super lput (length filter [? > 0] capabilities-frequency-Super) run-data-capabilities-Super
      foreach capabilities-diffusion-Super
        [ set run-data-capabilities-diffusion-Super lput ? run-data-capabilities-diffusion-Super ]
    ]
  ]
end


;;; EXPORT NETWORK DATA
;;;
;;; export network data to specific formats


;observer procedure
to export-network-data [export-to-simdb?]
  export-network-data-gml export-to-simdb? false
  export-network-data-gml export-to-simdb? true
  export-network-data-gexf export-to-simdb? false
  export-network-data-gexf export-to-simdb? true
  ;export-network-data-dyn-gexf export-to-simdb? false
  ;export-network-data-dyn-gexf export-to-simdb? true
  if super? [
    export-network-data-gml-super export-to-simdb? false
    export-network-data-gml-super export-to-simdb? true
    export-network-data-gexf-super export-to-simdb? false
    export-network-data-gexf-super export-to-simdb? true
    ;export-network-data-dyn-gexf-super export-to-simdb? false
    ;export-network-data-dyn-gexf-super export-to-simdb? true
  ]
end


; remove surrounding ""

to-report trim [ a-string ]
  ifelse not empty? a-string [
    ifelse (length a-string > 2) and (first a-string = "\"") and (last a-string = "\"")
      [ report substring a-string 1 (length a-string - 2) ]
      [ report a-string ]
  ] [
    report ""
  ]
end


; change & to &amp;

to-report escape [a-string]
  ifelse not empty? a-string [
    let pos position "&" a-string
    ifelse pos = false
      [ report a-string ]
      [ report replace-item pos a-string "&amp;" ]
  ] [
    report ""
  ]
end


; export network data in gml format

;observer procedure
to export-network-data-gml [export-to-simdb? weighted?]
  let sep pathdir:get-separator
  let file-name ""
  ifelse export-to-simdb? [
    let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "netdata" sep "gml" sep)
    set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number " " ticks)
  ] [
    set file-name (word "work" sep "netdata" sep "gml" sep ticks)
  ]
  ifelse weighted?
    [ set file-name (word file-name ".weighted.gml") ]
    [ set file-name (word file-name ".gml") ]
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants with [count my-network > 0]
  file-print "graph ["
  ; nodes
  foreach participants-list [
    file-print "  node ["
    file-print (word "    id \"" [my-nr] of ? "\"")
    file-print (word "    snr \"" [my-snr] of ? "\"")
    file-print (word "    type \"" [my-type] of ? "\"")
    file-print (word "    name \"" trim [my-name] of ? "\"")
    file-print "  ]"
  ]
  ; edges
  let n count participants
  foreach participants-list [
    let mynr [my-nr] of ?
    ask ? [
      foreach filter [[my-nr] of ? > mynr] participants-list [
        if member? ? my-network [
          let weight 1
          if weighted? [
            ; weight (number of edges) reflects history of partnerships
            let index ((mynr - 1) * n) + [my-nr] of ? - 1
            set weight array:item partnerships-matrix index
          ]
          let w 1
          while [w <= weight] [
            file-print "  edge ["
            file-print (word "    source \"" mynr "\"")
            file-print (word "    target \"" [my-nr] of ? "\"")
            file-print "  ]"
            set w w + 1
          ]
        ]
      ]
    ]
  ]
  file-print "]"
  file-close
end


;observer procedure
to export-network-data-gml-super [export-to-simdb? weighted?]
  ; aggregate participants data
  let participants-snr sort remove-duplicates [my-snr] of participants
  let participants-network []
  let participants-type []
  foreach participants-snr [
    let previous-partners no-turtles
    ask participants with [my-snr = ?]
      [ set previous-partners (turtle-set previous-partners my-previous-partners) ]
    ask participants with [my-snr = ?]
      [ set previous-partners previous-partners with [self != myself] ]
    set participants-network lput (sort remove-duplicates [my-snr] of previous-partners) participants-network
    ask one-of participants with [my-snr = ?]
      [ set participants-type lput my-type participants-type ]
  ]

  let sep pathdir:get-separator
  let file-name ""
  ifelse export-to-simdb? [
    let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "netdata" sep "gml" sep)
    set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number " " ticks ".super")
  ] [
    set file-name (word "work" sep "netdata" sep "gml" sep ticks ".super")
  ]
  ifelse weighted?
    [ set file-name (word file-name ".weighted.gml") ]
    [ set file-name (word file-name ".gml") ]
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  file-print "graph ["
  ; nodes
  let pos 0
  foreach participants-snr [
    let network item pos participants-network
    if not empty? network [
      file-print "  node ["
      file-print (word "    id \"" ? "\"")
      file-print (word "    type \"" item pos participants-type "\"")
      file-print "  ]"
    ]
    set pos pos + 1
  ]
  ; edges
  set pos 0
  let n count participants
  foreach participants-snr [
    let network item pos participants-network
    if not empty? network [
      let snr ?
      foreach filter [? > snr] participants-snr [
        if member? ? network [
          let weight 1
          if weighted? [
            ; weight (number of edges) reflects history of partnerships
            let index ((snr - 1) * n) + ? - 1
            set weight array:item partnerships-matrix-Super index
          ]
          let w 1
          while [w <= weight] [
            file-print "  edge ["
            file-print (word "    source \"" snr "\"")
            file-print (word "    target \"" ? "\"")
            file-print "  ]"
            set w w + 1
          ]
        ]
      ]
    ]
    set pos pos + 1
  ]
  file-print "]"
  file-close
end


; export network data in gexf format

;observer procedure
to export-network-data-gexf [export-to-simdb? weighted?]
  let sep pathdir:get-separator
  let file-name ""
  ifelse export-to-simdb? [
    let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "netdata" sep "gexf" sep)
    set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number " " ticks)
  ] [
    set file-name (word "work" sep "netdata" sep "gexf" sep ticks)
  ]
  ifelse weighted?
    [ set file-name (word file-name ".weighted.gexf") ]
    [ set file-name (word file-name ".gexf") ]
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  file-print "<?xml version=\"1.0\" encoding=\"UTF?8\"?>"
  file-print "<gexf xmlns=\"http://www.gexf.net/1.2draft\""
  file-print "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema?instance\""
  file-print "      xsi:schemaLocation=\"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd\""
  file-print "      version=\"1.2\">"
  file-print (word "  <meta lastmodifieddate=\"" date-and-time "\">")
  file-print (word "    <creator>" model-version "</creator>")
  file-print (word "    <description>exported netdata</description>")
  file-print "  </meta>"
  file-print "  <graph defaultedgetype=\"undirected\">"
  file-print "    <attributes class=\"node\" mode=\"static\">"
  file-print "      <attribute id=\"0\" title=\"snr\"  type=\"string\"/>"
  file-print "      <attribute id=\"1\" title=\"type\" type=\"string\"/>"
  file-print "      <attribute id=\"2\" title=\"name\" type=\"string\"/>"
  file-print "    </attributes>"
  ; nodes
  file-print "    <nodes>"
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants with [count my-network > 0]
  foreach participants-list [
    file-print (word "      <node id=\"" [my-nr] of ? "\" label=\"" [my-nr] of ? "\">")
    file-print "        <attvalues>"
    file-print (word "          <attvalue for=\"0\" value=\"" [my-snr] of ? "\"/>")
    file-print (word "          <attvalue for=\"1\" value=\"" [my-type] of ? "\"/>")
    file-print (word "          <attvalue for=\"2\" value=\"" escape trim [my-name] of ? "\"/>")
    file-print "        </attvalues>"
    file-print "      </node>"
  ]
  file-print "    </nodes>"
  ; edges
  file-print "    <edges>"
  let nr 1
  let n count participants
  foreach participants-list [
    let mynr [my-nr] of ?
    ask ? [
      foreach filter [[my-nr] of ? > mynr] participants-list [
        if member? ? my-network [
          let weight 1
          if weighted? [
            ; weight (number of edges) reflects history of partnerships
            let index ((mynr - 1) * n) + [my-nr] of ? - 1
            set weight array:item partnerships-matrix index
          ]
          file-print (word "      <edge id=\"" nr "\" source=\"" mynr "\" target=\"" [my-nr] of ? "\" weight=\"" weight "\"/>")
          set nr nr + 1
        ]
      ]
    ]
  ]
  file-print "    </edges>"
  file-print "  </graph>"
  file-print "</gexf>"
  file-close
end


;observer procedure
to export-network-data-gexf-super [export-to-simdb? weighted?]
  ; aggregate participants data
  let participants-snr sort remove-duplicates [my-snr] of participants
  let participants-network []
  let participants-type []
  foreach participants-snr [
    let previous-partners no-turtles
    ask participants with [my-snr = ?]
      [ set previous-partners (turtle-set previous-partners my-previous-partners) ]
    ask participants with [my-snr = ?]
      [ set previous-partners previous-partners with [self != myself] ]
    set participants-network lput (sort remove-duplicates [my-snr] of previous-partners) participants-network
    ask one-of participants with [my-snr = ?]
      [ set participants-type lput my-type participants-type ]
  ]

  let sep pathdir:get-separator
  let file-name ""
  ifelse export-to-simdb? [
    let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "netdata" sep "gexf" sep)
    set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number " " ticks ".super")
  ] [
    set file-name (word "work" sep "netdata" sep "gexf" sep ticks ".super")
  ]
  ifelse weighted?
    [ set file-name (word file-name ".weighted.gexf") ]
    [ set file-name (word file-name ".gexf") ]
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  file-print "<?xml version=\"1.0\" encoding=\"UTF?8\"?>"
  file-print "<gexf xmlns=\"http://www.gexf.net/1.2draft\""
  file-print "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema?instance\""
  file-print "      xsi:schemaLocation=\"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd\""
  file-print "      version=\"1.2\">"
  file-print (word "  <meta lastmodifieddate=\"" date-and-time "\">")
  file-print (word "    <creator>" model-version "</creator>")
  file-print (word "    <description>exported netdata</description>")
  file-print "  </meta>"
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
  file-print "  <graph defaultedgetype=\"undirected\">"
  file-print "    <attributes class=\"node\" mode=\"static\">"
  file-print "      <attribute id=\"0\" title=\"type\" type=\"string\"/>"
  file-print "    </attributes>"
  ; nodes
  file-print "    <nodes>"
  let pos 0
  foreach participants-snr [
    let network item pos participants-network
    if not empty? network [
      file-print (word "      <node id=\"" ? "\" label=\"" ? "\">")
      file-print "        <attvalues>"
      file-print (word "          <attvalue for=\"0\" value=\"" item pos participants-type "\"/>")
      file-print "        </attvalues>"
      file-print "      </node>"
    ]
    set pos pos + 1
  ]
  file-print "    </nodes>"
  ; edges
  file-print "    <edges>"
  let nr 1
  set pos 0
  let n count participants
  foreach participants-snr [
    let network item pos participants-network
    if not empty? network [
      let snr ?
      foreach filter [? > snr] participants-snr [
        if member? ? network [
          let weight 1
          if weighted? [
            ; weight (number of edges) reflects history of partnerships
            let index ((snr - 1) * n) + ? - 1
            set weight array:item partnerships-matrix-Super index
          ]
          file-print (word "      <edge id=\"" nr "\" source=\"" snr "\" target=\"" ? "\" weight=\"" weight "\"/>")
          set nr nr + 1
        ]
      ]
    ]
    set pos pos + 1
  ]
  file-print "    </edges>"
  file-print "  </graph>"
  file-print "</gexf>"
  file-close
end


; export network data in dynamic gexf format

; This export format is one file that contains node and edge attributes values with time intervals.
; The format is described in the GEXF Working Group documentation. It is not used yet (as of November 2011).

;observer procedure
to export-network-data-dyn-gexf [export-to-simdb? weighted?]
  let n count participants

  if ticks = 1 [
    set nodes-att-values array:from-list n-values n [0]
    set edges-att-values array:from-list n-values (n * n) [0]
  ]

  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
  foreach participants-list [
    let index ([my-nr] of ?) - 1
    let node-att-values array:item nodes-att-values index

    let att-values [0 0 0]
    set att-values replace-item 0 att-values [count my-network] of ?
    set att-values replace-item 1 att-values ticks
    set att-values replace-item 2 att-values (ticks + 5)

    ifelse node-att-values != 0
      [ array:set nodes-att-values index (lput att-values node-att-values) ]
      [ array:set nodes-att-values index (lput att-values []) ]
  ]

  foreach participants-list [
    let mynr [my-nr] of ?
    ask ? [
      foreach filter [[my-nr] of ? > mynr] participants-list [
        if member? ? my-network [
          let index ((mynr - 1) * n) + [my-nr] of ? - 1
          let edge-att-values array:item edges-att-values index

          let weight 1
          if weighted? [
            ; weight (number of edges) reflects history of partnerships
            set weight array:item partnerships-matrix index
          ]

          let att-values [0 0 0]
          set att-values replace-item 0 att-values weight
          set att-values replace-item 1 att-values ticks
          set att-values replace-item 2 att-values (ticks + 5)

          ifelse edge-att-values != 0
            [ array:set edges-att-values index (lput att-values edge-att-values) ]
            [ array:set edges-att-values index (lput att-values []) ]
        ]
      ]
    ]
  ]

  if ticks = nMonths [
    ; create 1 file only
    let sep pathdir:get-separator
    let file-name ""
    ifelse export-to-simdb? [
      let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "netdata" sep "gexf" sep "dyn" sep)
      set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number)
    ] [
      set file-name (word "work" sep "netdata" sep "gexf" sep "dyn" sep "1")
    ]
    ifelse weighted?
      [ set file-name (word file-name ".weighted.dyn.gexf") ]
      [ set file-name (word file-name ".dyn.gexf") ]
    if file-exists? file-name [ file-delete file-name ]
    file-open file-name
    file-print "<?xml version=\"1.0\" encoding=\"UTF?8\"?>"
    file-print "<gexf xmlns=\"http://www.gexf.net/1.2draft\""
    file-print "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema?instance\""
    file-print "      xsi:schemaLocation=\"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd\""
    file-print "      version=\"1.2\">"
    file-print (word "  <meta lastmodifieddate=\"" date-and-time "\">")
    file-print (word "    <creator>" model-version "</creator>")
    file-print (word "    <description>exported netdata</description>")
    file-print "  </meta>"
    file-print "  <graph mode=\"dynamic\" defaultedgetype=\"undirected\""
    file-print (word "         timeformat=\"integer\" start=\"" 1 "\" end=\"" nMonths "\">")
    file-print "    <attributes class=\"node\" mode=\"static\">"
    file-print "      <attribute id=\"0\" title=\"snr\" type=\"string\"/>"
    file-print "      <attribute id=\"1\" title=\"type\" type=\"string\"/>"
    file-print "      <attribute id=\"2\" title=\"name\" type=\"string\"/>"
    file-print "    </attributes>"
    file-print "    <attributes class=\"node\" mode=\"dynamic\">"
    file-print "      <attribute id=\"3\" title=\"val\" type=\"float\"/>"
    file-print "    </attributes>"
    file-print "    <attributes class=\"edge\" mode=\"dynamic\">"
    file-print "      <attribute id=\"weight\" title=\"Weight\" type=\"float\"/>"
    file-print "    </attributes>"
    ; nodes
    file-print "    <nodes>"
    foreach participants-list [
      file-print (word "      <node id=\"" [my-nr] of ? "\" label=\"" [my-nr] of ? "\">")
      file-print "        <attvalues>"
      file-print (word "          <attvalue for=\"0\" value=\"" [my-snr] of ? "\"/>")
      file-print (word "          <attvalue for=\"1\" value=\"" [my-type] of ? "\"/>")
      file-print (word "          <attvalue for=\"2\" value=\"" escape trim [my-name] of ? "\"/>")
      let index ([my-nr] of ?) - 1
      let node-att-values array:item nodes-att-values index
      if node-att-values != 0 [
        foreach node-att-values [
          let val-att item 0 ?  let start-att item 1 ?  let end-att item 2 ?
          file-type (word "          <attvalue for=\"val\" value=\"" val-att "\"")
          if start-att != 0 [ file-type (word " start=\"" start-att "\"") ]
          if end-att != 0 [ file-type (word " end=\"" end-att "\"") ]
          file-print "/>"
        ]
      ]
      file-print "        </attvalues>"
      file-print "      </node>"
    ]
    file-print "    </nodes>"
    ; edges
    file-print "    <edges>"
    let nr 1
    foreach participants-list [
      let mynr [my-nr] of ?
      ask ? [
        foreach filter [[my-nr] of ? > mynr] participants-list [
          let index ((mynr - 1) * n) + [my-nr] of ? - 1
          let edge-att-values array:item edges-att-values index
          if edge-att-values != 0 [
            file-print (word "      <edge id=\"" nr "\" source=\"" mynr "\" target=\"" [my-nr] of ? "\">")
            file-print "        <attvalues>"
            foreach edge-att-values [
              let weight-att item 0 ?  let start-att item 1 ?  let end-att item 2 ?
              file-type (word "          <attvalue for=\"weight\" value=\"" weight-att "\"")
              if start-att != 0 [ file-type (word " start=\"" start-att "\"") ]
              if end-att != 0 [ file-type (word " end=\"" end-att "\"") ]
              file-print "/>"
            ]
            file-print "        </attvalues>"
            file-print "      </edge>"
            set nr nr + 1
          ]
        ]
      ]
    ]
    file-print "    </edges>"
    file-print "  </graph>"
    file-print "</gexf>"
    file-close
  ]
end


;observer procedure
to export-network-data-dyn-gexf-super [export-to-simdb? weighted?]
  ; aggregate participants data
  let participants-snr sort remove-duplicates [my-snr] of participants
  let participants-network []
  let participants-type []
  foreach participants-snr [
    let previous-partners no-turtles
    ask participants with [my-snr = ?]
      [ set previous-partners (turtle-set previous-partners my-previous-partners) ]
    ask participants with [my-snr = ?]
      [ set previous-partners previous-partners with [self != myself] ]
    set participants-network lput (sort remove-duplicates [my-snr] of previous-partners) participants-network
    ask one-of participants with [my-snr = ?]
      [ set participants-type lput my-type participants-type ]
  ]

  ifelse ticks = 1 [
    let n count participants
    ; create 1 file only
    let sep pathdir:get-separator
    let file-name ""
    ifelse export-to-simdb? [
      let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "netdata" sep "gexf" sep "dyn" sep)
      set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number ".super")
    ] [
      set file-name (word "work" sep "netdata" sep "gexf" sep "dyn" sep "1.super")
    ]
    ifelse weighted?
      [ set file-name (word file-name ".weighted.dyn.gexf") ]
      [ set file-name (word file-name ".dyn.gexf") ]
    if file-exists? file-name [ file-delete file-name ]
    file-open file-name
    file-print "<?xml version=\"1.0\" encoding=\"UTF?8\"?>"
    file-print "<gexf xmlns=\"http://www.gexf.net/1.2draft\""
    file-print "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema?instance\""
    file-print "      xsi:schemaLocation=\"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd\""
    file-print "      version=\"1.2\">"
    file-print (word "  <meta lastmodifieddate=\"" date-and-time "\">")
    file-print (word "    <creator>" model-version "</creator>")
    file-print (word "    <description>exported netdata</description>")
    file-print "  </meta>"
    file-print "  <graph mode=\"dynamic\" defaultedgetype=\"undirected\""
    file-print (word "         timeformat=\"integer\" start=\"" 1 "\" end=\"" nMonths "\">")
    file-print "    <attributes class=\"node\" mode=\"static\">"
    file-print "      <attribute id=\"0\" title=\"type\" type=\"string\"/>"
    file-print "    </attributes>"
    ; nodes
    file-print "    <nodes>"
    let pos 0
    foreach participants-snr [
      file-print (word "      <node id=\"" ? "\" label=\"" ? "\">")
      file-print "        <attvalues>"
      file-print (word "          <attvalue for=\"0\" value=\"" item pos participants-type "\"/>")
      file-print "        </attvalues>"
      file-print "      </node>"
      set pos pos + 1
    ]
    file-print "    </nodes>"
    ; edges
    file-print "    <edges>"
  ] [
    let sep pathdir:get-separator
    let file-name ""
    ifelse export-to-simdb? [
      let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "netdata" sep "gexf" sep "dyn" sep)
      set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number ".super")
    ] [
      set file-name (word "netdata" sep "gexf" sep "dyn" sep "1.super")
    ]
    ifelse weighted?
      [ set file-name (word file-name ".weighted.dyn.gexf") ]
      [ set file-name (word file-name ".dyn.gexf") ]
    file-open file-name
  ]
  let nr 1
  let ticks-nr ""
  let n count participants
  foreach participants-snr [
    let snr ?
    foreach filter [? > snr] participants-snr [
      let weight 1
      if weighted? [
        ; weight (number of edges) reflects history of partnerships
        let index ((snr - 1) * n) + ? - 1
        set weight array:item partnerships-matrix-Super index
      ]
      set ticks-nr (word ticks "-" nr)
      file-print (word "      <edge id=\"" ticks-nr "\" source=\"" snr "\" target=\"" ? "\" weight=\"" weight "\"")
      file-print (word "            start=\"" ticks "\" end=\"" (ticks + 10) "\"/>")
      set nr nr + 1
    ]
  ]
  ifelse ticks = nMonths [
    file-print "    </edges>"
    file-print "  </graph>"
    file-print "</gexf>"
    file-close
  ] [
    file-close
  ]
end


;;; EXPORT KNOWLEDGE DATA
;;;
;;; export knowledge data to .csv file


;observer procedure
to export-knowledge-data [export-to-simdb?]
  let sep pathdir:get-separator
  let file-name ""
  ifelse export-to-simdb? [
    let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "kdata" sep)
    set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number " " ticks ".csv")
  ] [
    set file-name (word "work" sep "kdata" sep ticks ".csv")
  ]
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name

  foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [
    file-type (word [my-nr] of ? ",")
    file-type (word [my-snr] of ? ",")
    file-type (word [my-type] of ? ",")
    if not Empirical-case? [
      let capabilities-list sort [my-capabilities] of ?
      let i 0
      foreach capabilities-list [
        ifelse i > 0
          [ file-type (word "," ?) ]
          [ file-type ? ]
        set i i + 1
      ]
      file-print ""
    ]
  ]

  file-close

  if super?
    [ export-knowledge-data-super export-to-simdb? ]
end


;observer procedure
to export-knowledge-data-super [export-to-simdb?]
  let sep pathdir:get-separator
  let file-name ""
  ifelse export-to-simdb? [
    let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "kdata" sep)
    set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number " " ticks ".super.csv")
  ] [
    set file-name (word "work" sep "kdata" sep ticks ".super.csv")
  ]
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name

  ;;; aggregate
  let participants-snr sort remove-duplicates [my-snr] of participants
  foreach participants-snr [
    file-type (word ? ",")
    ; aggregate type
    ask one-of participants with [my-snr = ?]
      [ file-type (word my-type ",") ]
    ; aggregate capabilities
    if not Empirical-case? [
      let capabilities-list []
      ask participants with [my-snr = ?]
        [ set capabilities-list (sentence capabilities-list my-capabilities) ]
      set capabilities-list sort remove-duplicates capabilities-list
      let i 0
      foreach capabilities-list [
        ifelse i > 0
          [ file-type (word "," ?) ]
          [ file-type ? ]
        set i i + 1
      ]
      file-print ""
    ]
  ]

  file-close
end


;;; EXPORT RUN DATA
;;;
;;; export run data to .csv file

;observer procedure
to export-run-data [export-to-simdb?]
  let sep pathdir:get-separator
  let file-name ""
  ifelse export-to-simdb? [
    let file-location (word Simdb-location sep "infsoskin" Model-version sep Experiment-name sep "data" sep "rundata" sep)
    set file-name (word file-location "infsoskin" Model-version " " Experiment-name " " behaviorspace-run-number ".csv")
  ] [
    set file-name (word "work" sep "rundata" sep ticks ".csv")
  ]
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name

  file-print (word "Model-version,"   Model-version)
  file-print (word "Experiment-name," Experiment-name)
  file-print (word "Run-number,"      behaviorspace-run-number)
  file-print (word "date-and-time,"   date-and-time)
  file-print ""

  ;;; Inputs

  file-print (word "nMonths," nMonths)
  file-print (word "Empirical-case," Empirical-case?)
  file-print (word "Instrument-filter," Instrument-filter)
  file-print ""

  ; export presets only if relevant
  if not Empirical-case? [
    file-print (word "Participants-settings," Participants-settings)
    file-print (word "Instruments-settings,"  Instruments-settings)
    file-print (word "Calls-settings,"        Calls-settings)
    file-print (word "Themes-settings,"       Themes-settings)
    file-print (word "Other-settings,"        Other-settings)
    file-print ""

    file-print ";Participants-settings,RES,DFI,SME,CSO"
    file-print (word "nParticipants," nParticipants)
    file-print (word "Percent,"       Perc-RES "," Perc-DFI "," Perc-SME "," Perc-CSO)
    file-print (word "Size,"          Size-RES "," Size-DFI "," Size-SME "," Size-CSO)
    file-print ""

    file-print ";Instruments-settings,CIP"
    file-print (word "Size-min,"         Size-min-CIP)
    file-print (word "Size-max,"         Size-max-CIP)
    file-print (word "RES-min,"          RES-min-CIP)
    file-print (word "DFI-min,"          DFI-min-CIP)
    file-print (word "SME-min,"          SME-min-CIP)
    file-print (word "CSO-min,"          CSO-min-CIP)
    file-print (word "Duration-avg,"     Duration-avg-CIP)
    file-print (word "Duration-stdev,"   Duration-stdev-CIP)
    file-print (word "Contribution-avg," Contribution-avg-CIP)
    file-print (word "Match,"            Match-CIP)
    file-print (word "SCI-score-min,"    SCI-min-CIP)
    file-print (word "RRI-score-min,"    RRI-min-CIP)
    file-print (word "RRI-balance,"      RRI-balance-CIP)
    file-print ""

    file-print ";Calls-settings,Call1,Call2,Call3,Call4,Call5,Call6"
    file-print (word "Type-Call,"        Type-Call1        "," Type-Call2        "," Type-Call3        "," Type-Call4        "," Type-Call5        "," Type-Call6)
    file-print (word "Deadline-Call,"    Deadline-Call1    "," Deadline-Call2    "," Deadline-Call3    "," Deadline-Call4    "," Deadline-Call5    "," Deadline-Call6)
    file-print (word "Funding-Call,"     Funding-Call1     "," Funding-Call2     "," Funding-Call3     "," Funding-Call4     "," Funding-Call5     "," Funding-Call6)
    file-print (word "Themes-Call,"      Themes-Call1      "," Themes-Call2      "," Themes-Call3      "," Themes-Call4      "," Themes-Call5      "," Themes-Call6)
    file-print (word "Range-Call,"       Range-Call1       "," Range-Call2       "," Range-Call3       "," Range-Call4       "," Range-Call5       "," Range-Call6)
    file-print (word "Orientation-Call," Orientation-Call1 "," Orientation-Call2 "," Orientation-Call3 "," Orientation-Call4 "," Orientation-Call5 "," Orientation-Call6)
    file-print ""

    file-print ";Themes-settings"
    file-print (word "nCapabilities,"                  nCapabilities)
    file-print (word "nThemes,"                        nThemes)
    file-print (word "sector-capabilities-per-theme,"  sector-capabilities-per-theme)
    file-print (word "common-capabilities-per-theme,"  common-capabilities-per-theme)
    file-print (word "rare-capabilities-per-theme,"    rare-capabilities-per-theme)
    file-print (word "special-capabilities-per-theme," special-capabilities-per-theme)
    file-print ""

    file-print ";Other-settings"
    file-print (word "funding,"                         funding)
    file-print (word "project-cap-ratio,"               project-cap-ratio)
    file-print (word "search-depth,"                    search-depth)
    file-print (word "invite-previous-partners-first?," invite-previous-partners-first?)
    file-print (word "time-before-call-deadline,"       time-before-call-deadline)
    file-print (word "time-before-project-start,"       time-before-project-start)
    file-print (word "time-between-deliverables,"       time-between-deliverables)
    file-print (word "max-deliverable-length,"          max-deliverable-length)
    file-print (word "sub-nr-max,"                      sub-nr-max)
    file-print (word "sub-size-min,"                    sub-size-min)
    file-print ""
  ]

  ;;; Outputs

  file-type "Month"
  let month 1
  while [month <= nMonths] [ file-type (word "," month)  set month month + 1 ]
  file-print ""

  file-type "participants-RES"              foreach run-data-participants-RES [ file-type (word "," ?) ]           file-print ""
  file-type "participants-RES-net"          foreach run-data-participants-RES-net [ file-type (word "," ?) ]       file-print ""
  file-type "participants-DFI"              foreach run-data-participants-DFI [ file-type (word "," ?) ]           file-print ""
  file-type "participants-DFI-net"          foreach run-data-participants-DFI-net [ file-type (word "," ?) ]       file-print ""
  file-type "participants-SME"              foreach run-data-participants-SME [ file-type (word "," ?) ]           file-print ""
  file-type "participants-SME-net"          foreach run-data-participants-SME-net [ file-type (word "," ?) ]       file-print ""
  file-type "participants-CSO"              foreach run-data-participants-CSO [ file-type (word "," ?) ]           file-print ""
  file-type "participants-CSO-net"          foreach run-data-participants-CSO-net [ file-type (word "," ?) ]       file-print ""
  if not Empirical-case? [
    file-type "proposals-submitted"         foreach run-data-proposals-submitted [ file-type (word "," ?) ]        file-print ""
    file-type "proposals"                   foreach run-data-proposals [ file-type (word "," ?) ]                  file-print ""
    file-type "proposals-with-SME"          foreach run-data-proposals-with-SME [ file-type (word "," ?) ]         file-print ""
    file-type "proposals-with-CSO"          foreach run-data-proposals-with-CSO [ file-type (word "," ?) ]         file-print ""
    file-type "proposals-small"             foreach run-data-proposals-small [ file-type (word "," ?) ]            file-print ""
    file-type "proposals-big"               foreach run-data-proposals-big [ file-type (word "," ?) ]              file-print ""
  ]
  file-type "projects-started"              foreach run-data-projects-started [ file-type (word "," ?) ]           file-print ""
  file-type "projects"                      foreach run-data-projects [ file-type (word "," ?) ]                   file-print ""
  file-type "projects-with-SME"             foreach run-data-projects-with-SME [ file-type (word "," ?) ]          file-print ""
  file-type "projects-with-CSO"             foreach run-data-projects-with-CSO [ file-type (word "," ?) ]          file-print ""
  file-type "projects-small"                foreach run-data-projects-small [ file-type (word "," ?) ]             file-print ""
  file-type "projects-big"                  foreach run-data-projects-big [ file-type (word "," ?) ]               file-print ""
  ;file-type "network-density"              foreach run-data-network-density [ file-type (word "," ?) ]            file-print ""
  ;file-type "network-components"           foreach run-data-network-components [ file-type (word "," ?) ]         file-print ""
  ;file-type "network-largest-component"    foreach run-data-network-largest-component [ file-type (word "," ?) ]  file-print ""
  ;file-type "network-avg-degree"           foreach run-data-network-avg-degree [ file-type (word "," ?) ]         file-print ""
  ;file-type "network-avg-path-length"      foreach run-data-network-avg-path-length [ file-type (word "," ?) ]    file-print ""
  ;file-type "network-clustering"           foreach run-data-network-clustering [ file-type (word "," ?) ]         file-print ""
  if not Empirical-case? [
    file-type "knowledge"                   foreach run-data-knowledge [ file-type (word "," ?) ]                  file-print ""
    file-type "knowledge-flow"              foreach run-data-knowledge-flow [ file-type (word "," ?) ]             file-print ""
    file-type "knowledge-RES-to-RES"        foreach run-data-kf-RES-to-RES [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-RES-to-DFI"        foreach run-data-kf-RES-to-DFI [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-RES-to-SME"        foreach run-data-kf-RES-to-SME [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-RES-to-CSO"        foreach run-data-kf-RES-to-CSO [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-DFI-to-RES"        foreach run-data-kf-DFI-to-RES [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-DFI-to-DFI"        foreach run-data-kf-DFI-to-DFI [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-DFI-to-SME"        foreach run-data-kf-DFI-to-SME [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-DFI-to-CSO"        foreach run-data-kf-DFI-to-CSO [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-SME-to-RES"        foreach run-data-kf-SME-to-RES [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-SME-to-DFI"        foreach run-data-kf-SME-to-DFI [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-SME-to-SME"        foreach run-data-kf-SME-to-SME [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-SME-to-CSO"        foreach run-data-kf-SME-to-CSO [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-CSO-to-RES"        foreach run-data-kf-CSO-to-RES [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-CSO-to-DFI"        foreach run-data-kf-CSO-to-DFI [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-CSO-to-SME"        foreach run-data-kf-CSO-to-SME [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-CSO-to-CSO"        foreach run-data-kf-CSO-to-CSO [ file-type (word "," ?) ]              file-print ""
    file-type "knowledge-patents"           foreach run-data-knowledge-patents [ file-type (word "," ?) ]          file-print ""
    file-type "knowledge-articles"          foreach run-data-knowledge-articles [ file-type (word "," ?) ]         file-print ""
    file-type "capabilities"                foreach run-data-capabilities [ file-type (word "," ?) ]               file-print ""
    let theme 1
    while [theme <= nThemes] [
      file-type (word "capabilities-diffusion-Theme" theme)
      let i 0
      foreach run-data-capabilities-diffusion [
        if i mod nThemes = theme - 1
          [ file-type (word "," ?) ]
        set i i + 1
      ]
      file-print ""
      set theme theme + 1
    ]
  ]
  ;;;
  if super? [
    file-type "participants-RES-Super"      foreach run-data-participants-RES-Super [ file-type (word "," ?) ]     file-print ""
    file-type "participants-RES-net-Super"  foreach run-data-participants-RES-net-Super [ file-type (word "," ?) ] file-print ""
    file-type "participants-DFI-Super"      foreach run-data-participants-DFI-Super [ file-type (word "," ?) ]     file-print ""
    file-type "participants-DFI-net-Super"  foreach run-data-participants-DFI-net-Super [ file-type (word "," ?) ] file-print ""
    file-type "participants-SME-Super"      foreach run-data-participants-SME-Super [ file-type (word "," ?) ]     file-print ""
    file-type "participants-SME-net-Super"  foreach run-data-participants-SME-net-Super [ file-type (word "," ?) ] file-print ""
    file-type "participants-CSO-Super"      foreach run-data-participants-CSO-Super [ file-type (word "," ?) ]     file-print ""
    file-type "participants-CSO-net-Super"  foreach run-data-participants-CSO-net-Super [ file-type (word "," ?) ] file-print ""
    if not Empirical-case? [
      file-type "proposals-small-Super"     foreach run-data-proposals-small-Super [ file-type (word "," ?) ]      file-print ""
      file-type "proposals-big-Super"       foreach run-data-proposals-big-Super [ file-type (word "," ?) ]        file-print ""
    ]
    file-type "projects-small-Super"        foreach run-data-projects-small-Super [ file-type (word "," ?) ]       file-print ""
    file-type "projects-big-Super"          foreach run-data-projects-big-Super [ file-type (word "," ?) ]         file-print ""
    if not Empirical-case? [
      file-type "capabilities-Super"        foreach run-data-capabilities-Super [ file-type (word "," ?) ]         file-print ""
      let theme 1
      while [theme <= nThemes] [
        file-type (word "capabilities-diffusion-Theme" theme "-Super")
        let i 0
        foreach run-data-capabilities-diffusion-Super [
          if i mod nThemes = theme - 1
            [ file-type (word "," ?) ]
          set i i + 1
        ]
        file-print ""
        set theme theme + 1
      ]
    ]
  ]

  file-print ""

  file-type "participants-type"             foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [ file-type (word "," [my-type] of ?) ]  file-print ""
  if not Empirical-case?
    [ file-type "participants-size"         foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [ file-type (word "," [my-cap-capacity] of ?) ]  file-print "" ]
  file-type "participants-partners"         foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [ file-type (word "," count [my-previous-partners] of ?) ]  file-print ""
  if not Empirical-case?
    [ file-type "participants-proposals"    foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [ file-type (word "," [length participation-in-proposals] of ?) ]  file-print "" ]
  file-type "participants-projects"         foreach sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants [ file-type (word "," [length participation-in-projects] of ?) ]  file-print ""
  if not Empirical-case? [
    file-type "proposals-type"              foreach proposals-type [ file-type (word "," ?) ]              file-print ""
    file-type "proposals-call"              foreach proposals-call [ file-type (word "," ?) ]              file-print ""
    file-type "proposals-size"              foreach proposals-size [ file-type (word "," ?) ]              file-print ""
    file-type "proposals-RES"               foreach proposals-RES [ file-type (word "," ?) ]               file-print ""
    file-type "proposals-DFI"               foreach proposals-DFI [ file-type (word "," ?) ]               file-print ""
    file-type "proposals-SME"               foreach proposals-SME [ file-type (word "," ?) ]               file-print ""
    file-type "proposals-CSO"               foreach proposals-CSO [ file-type (word "," ?) ]               file-print ""
    file-type "proposals-expertise-level"   foreach proposals-expertise-level [ file-type (word "," ?) ]   file-print ""
    file-type "proposals-capability-match"  foreach proposals-capability-match [ file-type (word "," ?) ]  file-print ""
  ]
  file-type "projects-type"                 foreach projects-type [ file-type (word "," ?) ]               file-print ""
  file-type "projects-call"                 foreach projects-call [ file-type (word "," ?) ]               file-print ""
  file-type "projects-size"                 foreach projects-size [ file-type (word "," ?) ]               file-print ""
  file-type "projects-RES"                  foreach projects-RES [ file-type (word "," ?) ]                file-print ""
  file-type "projects-DFI"                  foreach projects-DFI [ file-type (word "," ?) ]                file-print ""
  file-type "projects-SME"                  foreach projects-SME [ file-type (word "," ?) ]                file-print ""
  file-type "projects-CSO"                  foreach projects-CSO [ file-type (word "," ?) ]                file-print ""
  file-type "projects-duration"             foreach projects-duration [ file-type (word "," ?) ]           file-print ""
  file-type "projects-contribution"         foreach projects-contribution [ file-type (word "," ?) ]       file-print ""
  if not Empirical-case? [
    file-type "kenes-length"
    let kenes-length (sentence kenes-length-RES kenes-length-DFI kenes-length-SME kenes-length-CSO)
    foreach kenes-length [ file-type (word "," ?) ]  file-print ""
    file-type "capabilities-frequency"
    let capabilities-frequency (map [?1 + ?2 + ?3 + ?4] capabilities-frequency-RES capabilities-frequency-DFI capabilities-frequency-SME capabilities-frequency-CSO)
    foreach capabilities-frequency [ file-type (word "," ?) ]  file-print ""
  ]

  ;;; aggregate participants data
  if super? [
    let participants-snr sort remove-duplicates [my-snr] of participants
    let participants-type-Super []
    let participants-size-Super []
    let participants-partners-Super []
    let participants-proposals-Super []
    let participants-projects-Super []
    foreach participants-snr [
      ; aggregate type
      ask one-of participants with [my-snr = ?]
        [ set participants-type-Super lput my-type participants-type-Super ]
      ; aggregate size
      if not Empirical-case? [
        let size-Super 0
        ask participants with [my-snr = ?]
          [ set size-Super size-Super + my-cap-capacity ]
        set participants-size-Super lput size-Super participants-size-Super
      ]
      ; aggregate partners
      let partners-Super no-turtles
      ask participants with [my-snr = ?]
        [ set partners-Super (turtle-set partners-Super my-previous-partners) ]
      ask participants with [my-snr = ?]
        [ set partners-Super partners-Super with [self != myself] ]
      set participants-partners-Super lput (length remove-duplicates [my-snr] of partners-Super) participants-partners-Super
      ; aggregate proposals
      if not Empirical-case? [
        let proposals-Super []
        ask participants with [my-snr = ?]
          [ set proposals-Super (sentence proposals-Super participation-in-proposals) ]
        set participants-proposals-Super lput (length remove-duplicates proposals-Super) participants-proposals-Super
      ]
      ; aggregate projects
      let projects-Super []
      ask participants with [my-snr = ?]
        [ set projects-Super (sentence projects-Super participation-in-projects) ]
      set participants-projects-Super lput (length remove-duplicates projects-Super) participants-projects-Super
    ]
    file-type "participants-snr"                  foreach participants-snr [ file-type (word "," ?) ]              file-print ""
    file-type "participants-snr-count"            foreach participants-snr [ file-type (word "," count participants with [my-snr = ?]) ]  file-print ""
    file-type "participants-snr-net-count"        foreach participants-snr [ file-type (word "," count participants with [(my-snr = ?) and (count my-previous-partners > 0)]) ]  file-print ""
    file-type "participants-type-Super"           foreach participants-type-Super [ file-type (word "," ?) ]       file-print ""
    if not Empirical-case?
      [ file-type "participants-size-Super"       foreach participants-size-Super [ file-type (word "," ?) ]       file-print "" ]
    file-type "participants-partners-Super"       foreach participants-partners-Super [ file-type (word "," ?) ]   file-print ""
    if not Empirical-case?
      [ file-type "participants-proposals-Super"  foreach participants-proposals-Super [ file-type (word "," ?) ]  file-print "" ]
    file-type "participants-projects-Super"       foreach participants-projects-Super [ file-type (word "," ?) ]   file-print ""
    if not Empirical-case? [
      file-type "proposals-size-Super"            foreach proposals-size-Super [ file-type (word "," ?) ]          file-print ""
      file-type "proposals-RES-Super"             foreach proposals-RES-Super [ file-type (word "," ?) ]           file-print ""
      file-type "proposals-DFI-Super"             foreach proposals-DFI-Super [ file-type (word "," ?) ]           file-print ""
      file-type "proposals-SME-Super"             foreach proposals-SME-Super [ file-type (word "," ?) ]           file-print ""
      file-type "proposals-CSO-Super"             foreach proposals-CSO-Super [ file-type (word "," ?) ]           file-print ""
    ]
    file-type "projects-size-Super"               foreach projects-size-Super [ file-type (word "," ?) ]           file-print ""
    file-type "projects-RES-Super"                foreach projects-RES-Super [ file-type (word "," ?) ]            file-print ""
    file-type "projects-DFI-Super"                foreach projects-DFI-Super [ file-type (word "," ?) ]            file-print ""
    file-type "projects-SME-Super"                foreach projects-SME-Super [ file-type (word "," ?) ]            file-print ""
    file-type "projects-CSO-Super"                foreach projects-CSO-Super [ file-type (word "," ?) ]            file-print ""
    if not Empirical-case? [
      file-type "kenes-length-Super"
      let kenes-length-Super (sentence kenes-length-RES-Super kenes-length-DFI-Super kenes-length-SME-Super kenes-length-CSO-Super)
      foreach kenes-length-Super [ file-type (word "," ?) ]  file-print ""
      file-type "capabilities-frequency-Super"
      let capabilities-frequency-Super (map [?1 + ?2 + ?3 + ?4] capabilities-frequency-RES-Super capabilities-frequency-DFI-Super capabilities-frequency-SME-Super capabilities-frequency-CSO-Super)
      foreach capabilities-frequency-Super [ file-type (word "," ?) ]  file-print ""
    ]
  ]

  file-close
end

;; end of code
@#$#@#$#@
GRAPHICS-WINDOW
1568
13
1813
253
97
100
1.04103
1
10
1
1
1
0
0
0
1
-97
97
-100
100
0
0
1
ticks
30.0

BUTTON
925
35
995
68
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
995
35
1065
68
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
220
40
312
73
nParticipants
nParticipants
0
5000
110
100
1
NIL
HORIZONTAL

PLOT
1360
35
1675
220
Proposals Submitted
Time (Months)
Count
0.0
120.0
0.0
20.0
true
false
"" ""
PENS
"" 1.0 0 -7500403 true "" ""

PLOT
1360
220
1675
405
Projects Started
Time (Months)
Count
0.0
120.0
0.0
20.0
true
false
"" ""
PENS
"" 1.0 0 -16777216 true "" ""

PLOT
1360
405
1675
590
Projects Completed
Time (Months)
Count
0.0
120.0
0.0
20.0
true
false
"" ""
PENS
"all" 1.0 0 -16777216 true "" ""
"with CSO" 1.0 0 -2674135 true "" ""

SLIDER
220
145
312
178
Perc-SME
Perc-SME
0
100
36.4
1
1
NIL
HORIZONTAL

SLIDER
220
110
312
143
Perc-DFI
Perc-DFI
0
100
27.3
1
1
NIL
HORIZONTAL

MONITOR
1150
35
1285
80
Call 1
show-call-status 1
17
1
11

MONITOR
1150
80
1285
125
Call 2
show-call-status 2
17
1
11

MONITOR
1150
125
1285
170
Call 3
show-call-status 3
17
1
11

MONITOR
1150
170
1285
215
Call 4
show-call-status 4
17
1
11

MONITOR
1150
215
1285
260
Call 5
show-call-status 5
17
1
11

MONITOR
1150
260
1285
305
Call 6
show-call-status 6
17
1
11

MONITOR
2035
35
2100
80
RES
count participants with [my-type = \"res\"]
17
1
11

MONITOR
2100
35
2165
80
DFI
count participants with [my-type = \"dfi\"]
17
1
11

MONITOR
2165
35
2229
80
SME
count participants with [my-type = \"sme\"]
17
1
11

BUTTON
1065
35
1135
68
Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
2035
457
2205
502
Projects completed
projects-count
17
1
11

MONITOR
1150
325
1285
370
Current Call
[call-nr] of the-current-call
17
1
11

MONITOR
1150
415
1285
460
Funding available
[call-funding] of the-current-call\n
17
1
11

MONITOR
1150
505
1285
550
Research orientation
[call-orientation] of the-current-call
17
1
11

MONITOR
2035
147
2205
192
Proposals initiated
show-call-counter \"initiated\"
17
1
11

MONITOR
2035
192
2205
237
Proposals stopped
show-call-counter \"stopped\"
17
1
11

MONITOR
2035
237
2205
282
Proposals submitted
show-call-counter \"submitted\"
17
1
11

MONITOR
2035
302
2205
347
Proposals eligible
show-call-counter \"eligible\"
17
1
11

MONITOR
2035
347
2205
392
Proposals accepted
show-call-counter \"accepted\"
17
1
11

MONITOR
2035
392
2205
437
Proposals rejected
show-call-counter \"rejected\"
17
1
11

MONITOR
2205
192
2290
237
% stopped
round (1000 * show-call-counter \"stopped\" / show-call-counter \"initiated\") / 10
17
1
11

MONITOR
2205
302
2290
347
% eligible
round (1000 * show-call-counter \"eligible\" / show-call-counter \"submitted\") / 10
17
1
11

MONITOR
2205
347
2290
392
% accepted
round (1000 * show-call-counter \"accepted\" / show-call-counter \"eligible\") / 10
17
1
11

MONITOR
2205
392
2290
437
% rejected
round (1000 * show-call-counter \"rejected\" / show-call-counter \"eligible\") / 10
17
1
11

MONITOR
1150
370
1285
415
Deadline
[call-deadline] of the-current-call
17
1
11

MONITOR
2205
237
2290
282
% submitted
round (1000 * show-call-counter \"submitted\" / show-call-counter \"initiated\") / 10
17
1
11

SLIDER
925
215
1135
248
nMonths
nMonths
0
120
120
1
1
NIL
HORIZONTAL

PLOT
1675
35
1990
220
Participation in Proposals
Number of Proposals
Frequency
1.0
50.0
0.0
50.0
false
false
"" ""
PENS
"" 1.0 1 -7500403 true "" ""

PLOT
1675
220
1990
405
Participation in Projects
Number of Projects
Frequency
1.0
50.0
0.0
50.0
false
false
"" ""
PENS
"" 1.0 1 -16777216 true "" ""

PLOT
1675
405
1990
590
Partners
Number of Partners
Frequency
1.0
50.0
0.0
50.0
false
false
"" ""
PENS
"" 1.0 1 -16777216 true "" ""

PLOT
925
605
1135
755
Proposals Size
Size
Frequency
1.0
40.0
0.0
10.0
true
false
"" ""
PENS
"" 1.0 1 -7500403 true "" ""

PLOT
925
755
1135
905
Projects Size
Size
Frequency
1.0
40.0
0.0
10.0
true
false
"" ""
PENS
"" 1.0 1 -16777216 true "" ""

PLOT
1575
605
1785
755
Capability Match (SCI Score)
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"" 5.0 1 -13791810 true "" ""

PLOT
1575
755
1785
905
Expertise Level (SCI Score)
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 5.0 1 -13791810 true "" ""

MONITOR
2205
610
2290
655
Density
round (1000 * density) / 1000
17
1
11

PLOT
2300
35
2520
185
Network Density
Time (Months)
NIL
0.0
120.0
0.0
0.1
false
false
"" ""
PENS
"" 1.0 0 -13345367 true "" ""

MONITOR
2035
655
2120
700
Components
number-of-components
17
1
11

PLOT
2300
185
2520
335
Number of Components
Time (Months)
NIL
0.0
120.0
0.0
1.0
false
false
"" ""
PENS
"" 1.0 0 -13345367 true "" ""

PLOT
2300
335
2520
485
Size of Largest Component
Time (Months)
NIL
0.0
120.0
0.0
100.0
true
false
"" ""
PENS
"" 1.0 0 -13345367 true "" ""

MONITOR
2120
655
2205
700
Size of largest component
largest-component-size
17
1
11

MONITOR
2205
655
2290
700
Avg. degree
round (1000 * average-degree) / 1000
17
1
11

PLOT
2520
35
2740
185
Average Degree
Time (Months)
NIL
0.0
120.0
0.0
50.0
false
false
"" ""
PENS
"" 1.0 0 -13345367 true "" ""

MONITOR
2120
700
2205
745
Avg. path length
round (1000 * average-path-length) / 1000
17
1
11

MONITOR
2205
700
2290
745
Clustering
round (1000 * clustering-coefficient) / 1000
17
1
11

PLOT
2520
185
2740
335
Average Path Length
Time (Months)
NIL
0.0
120.0
0.0
5.0
false
false
"" ""
PENS
"" 1.0 0 -13345367 true "" ""

PLOT
2520
335
2740
485
Clustering
Time (Months)
NIL
0.0
120.0
0.8
1.0
false
false
"" ""
PENS
"" 1.0 0 -13345367 true "" ""

MONITOR
2035
700
2120
745
Diameter
diameter
17
1
11

SWITCH
925
515
1135
548
Empirical-case?
Empirical-case?
1
1
-1000

CHOOSER
925
550
1135
595
Instrument-filter
Instrument-filter
"CIP"
0

MONITOR
2120
610
2205
655
Edges
count-of-edges
17
1
11

MONITOR
2035
610
2120
655
Nodes
count participants-in-net
17
1
11

MONITOR
2035
502
2120
547
Avg. size
round (10 * mean projects-size) / 10
17
1
11

MONITOR
2205
457
2290
502
% with CSO
round (1000 * projects-with-CSO-count / projects-count) / 10
17
1
11

MONITOR
2120
502
2205
547
Min. size
min projects-size
17
1
11

MONITOR
2120
547
2205
592
Max. size
max projects-size
17
1
11

MONITOR
2205
502
2290
547
% Small (<5)
round (1000 * length filter [? < 5] projects-size / projects-count) / 10
17
1
11

MONITOR
2205
547
2290
592
% Large (>25)
round (1000 * length filter [? > 25] projects-size / projects-count) / 10
17
1
11

MONITOR
2035
547
2120
592
Med. size
round (10 * median projects-size) / 10
17
1
11

PLOT
2300
792
2740
912
Knowledge Space
Themes/Capabilities
Freq.
1.0
1000.0
0.0
20.0
true
false
"" ""
PENS
"" 1.0 1 -7500403 false "" ""

PLOT
2520
492
2740
642
Knowledge Flow
Time (Months)
Flow
0.0
120.0
0.0
10.0
true
false
"" ""
PENS
"" 1.0 0 -16777216 true "" ""

PLOT
2300
492
2520
642
Knowledge
Time (Months)
Sum
0.0
120.0
0.0
10.0
true
false
"" ""
PENS
"" 1.0 0 -16777216 true "" ""

PLOT
2300
642
2520
792
Knowledge (Distribution)
Number of Capabilities
Frequency
0.0
50.0
0.0
50.0
false
false
"" ""
PENS
"" 1.0 1 -16777216 true "" ""

MONITOR
2036
776
2164
821
Knowledge (K)
0
17
1
11

MONITOR
2164
776
2292
821
Knowl. flow (Kf)
0
17
1
11

MONITOR
2036
868
2100
913
RES (med. K)
round (10 * median kenes-length-RES) / 10
17
1
11

MONITOR
2100
868
2164
913
DFI (med. K)
round (10 * median kenes-length-DFI) / 10
17
1
11

MONITOR
2164
868
2229
913
SME (med. K)
round (10 * median kenes-length-SME) / 10
17
1
11

MONITOR
2036
823
2100
868
RES (avg. K)
round (10 * mean kenes-length-RES) / 10
17
1
11

MONITOR
2100
823
2164
868
DFI (avg. K)
round (10 * mean kenes-length-DFI) / 10
17
1
11

MONITOR
2164
823
2229
868
SME (avg. K)
round (10 * mean kenes-length-SME) / 10
17
1
11

PLOT
2520
642
2740
792
Knowledge Flow (Detail)
Time (Months)
Flow
0.0
120.0
0.0
10.0
true
false
"" ""
PENS
"all" 1.0 0 -16777216 true "" ""
"with CSO" 1.0 0 -2674135 true "" ""

MONITOR
2035
80
2100
125
RES in net
count participants with [(my-type = \"res\") and (any? my-network)]
17
1
11

MONITOR
2100
80
2165
125
DFI in net
count participants with [(my-type = \"dfi\") and (any? my-network)]
17
1
11

MONITOR
2165
80
2229
125
SME in net
count participants with [(my-type = \"sme\") and (any? my-network)]
17
1
11

SLIDER
2745
35
2778
138
Update-Network-Measures-interval
Update-Network-Measures-interval
1
112
120
1
1
NIL
VERTICAL

SLIDER
220
75
312
108
Perc-RES
Perc-RES
0
100
27.3
1
1
NIL
HORIZONTAL

SLIDER
315
75
407
108
Size-RES
Size-RES
0
50
25
1
1
NIL
HORIZONTAL

SLIDER
315
110
407
143
Size-DFI
Size-DFI
0
50
15
1
1
NIL
HORIZONTAL

SLIDER
315
145
407
178
Size-SME
Size-SME
0
50
10
1
1
NIL
HORIZONTAL

TEXTBOX
175
85
200
103
RES
11
0.0
1

TEXTBOX
175
120
200
138
DFI
11
0.0
1

TEXTBOX
175
155
200
173
SME
11
0.0
1

SLIDER
220
250
312
283
Size-min-CIP
Size-min-CIP
0
100
5
1
1
NIL
HORIZONTAL

TEXTBOX
175
265
200
283
CIP
11
0.0
1

SLIDER
315
250
407
283
Size-max-CIP
Size-max-CIP
0
100
58
1
1
NIL
HORIZONTAL

SLIDER
410
250
502
283
Duration-avg-CIP
Duration-avg-CIP
0
100
31.8
1
1
NIL
HORIZONTAL

SLIDER
410
565
502
598
Funding-Call1
Funding-Call1
0
1000
16.7
1
1
NIL
HORIZONTAL

SLIDER
410
610
502
643
Funding-Call2
Funding-Call2
0
1000
16.7
1
1
NIL
HORIZONTAL

SLIDER
220
315
312
348
RES-min-CIP
RES-min-CIP
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
315
315
407
348
DFI-min-CIP
DFI-min-CIP
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
410
315
502
348
SME-min-CIP
SME-min-CIP
0
100
0
1
1
NIL
HORIZONTAL

CHOOSER
925
360
1135
405
Calls-settings
Calls-settings
"no preset" "Baseline (CIP)" "with special caps"
2

CHOOSER
925
405
1135
450
Themes-settings
Themes-settings
"no preset" "Baseline"
1

CHOOSER
925
450
1135
495
Other-settings
Other-settings
"no preset" "Baseline"
1

CHOOSER
925
270
1135
315
Participants-settings
Participants-settings
"no preset" "Small (no CSOs)" "Small with CSOs"
2

CHOOSER
925
315
1135
360
Instruments-settings
Instruments-settings
"no preset" "Baseline (0% RRI)" "Balanced (50% RRI)"
2

TEXTBOX
175
585
215
603
Call 1
11
0.0
1

SLIDER
410
655
502
688
Funding-Call3
Funding-Call3
0
1000
16.7
1
1
NIL
HORIZONTAL

SLIDER
410
700
502
733
Funding-Call4
Funding-Call4
0
1000
16.7
1
1
NIL
HORIZONTAL

SLIDER
410
745
502
778
Funding-Call5
Funding-Call5
0
1000
16.7
1
1
NIL
HORIZONTAL

SLIDER
410
790
502
823
Funding-Call6
Funding-Call6
0
1000
16.7
1
1
NIL
HORIZONTAL

SLIDER
695
565
787
598
Orientation-Call1
Orientation-Call1
0
9
5
1
1
NIL
HORIZONTAL

TEXTBOX
175
630
215
648
Call 2
11
0.0
1

TEXTBOX
175
675
215
693
Call 3
11
0.0
1

TEXTBOX
175
720
215
738
Call 4
11
0.0
1

TEXTBOX
175
765
215
783
Call 5
11
0.0
1

TEXTBOX
175
810
215
828
Call 6
11
0.0
1

SLIDER
695
610
787
643
Orientation-Call2
Orientation-Call2
0
9
5
1
1
NIL
HORIZONTAL

SLIDER
695
655
787
688
Orientation-Call3
Orientation-Call3
0
9
5
1
1
NIL
HORIZONTAL

SLIDER
695
700
787
733
Orientation-Call4
Orientation-Call4
0
9
5
1
1
NIL
HORIZONTAL

SLIDER
695
745
787
778
Orientation-Call5
Orientation-Call5
0
9
5
1
1
NIL
HORIZONTAL

SLIDER
695
790
787
823
Orientation-Call6
Orientation-Call6
0
9
5
1
1
NIL
HORIZONTAL

SLIDER
695
250
787
283
Match-CIP
Match-CIP
0
100
5
1
1
NIL
HORIZONTAL

SLIDER
505
565
597
598
Themes-Call1
Themes-Call1
1
10
10
1
1
NIL
HORIZONTAL

SLIDER
600
565
692
598
Range-Call1
Range-Call1
0
100
35
1
1
NIL
HORIZONTAL

CHOOSER
220
565
312
610
Type-Call1
Type-Call1
"CIP"
0

CHOOSER
220
610
312
655
Type-Call2
Type-Call2
"CIP"
0

CHOOSER
220
655
312
700
Type-Call3
Type-Call3
"CIP"
0

CHOOSER
220
700
312
745
Type-Call4
Type-Call4
"CIP"
0

CHOOSER
220
745
312
790
Type-Call5
Type-Call5
"CIP"
0

CHOOSER
220
790
312
835
Type-Call6
Type-Call6
"CIP"
0

SLIDER
505
610
597
643
Themes-Call2
Themes-Call2
1
10
10
1
1
NIL
HORIZONTAL

SLIDER
505
655
597
688
Themes-Call3
Themes-Call3
1
10
10
1
1
NIL
HORIZONTAL

SLIDER
505
700
597
733
Themes-Call4
Themes-Call4
1
10
10
1
1
NIL
HORIZONTAL

SLIDER
505
745
597
778
Themes-Call5
Themes-Call5
1
10
10
1
1
NIL
HORIZONTAL

SLIDER
505
790
597
823
Themes-Call6
Themes-Call6
1
10
10
1
1
NIL
HORIZONTAL

SLIDER
600
610
692
643
Range-Call2
Range-Call2
0
100
35
1
1
NIL
HORIZONTAL

TEXTBOX
255
295
285
313
RES
11
0.0
1

TEXTBOX
350
295
380
313
DFI
11
0.0
1

TEXTBOX
440
295
470
313
SME
11
0.0
1

SLIDER
600
250
692
283
Contribution-avg-CIP
Contribution-avg-CIP
0
100
2.5
1
1
NIL
HORIZONTAL

MONITOR
10
40
150
85
Participants-settings
Participants-settings
17
1
11

MONITOR
10
250
150
295
Instruments-settings
Instruments-settings
17
1
11

MONITOR
10
565
150
610
Calls-settings
Calls-settings
17
1
11

SLIDER
315
565
407
598
Deadline-Call1
Deadline-Call1
0
112
6
1
1
NIL
HORIZONTAL

SLIDER
315
610
407
643
Deadline-Call2
Deadline-Call2
0
112
18
1
1
NIL
HORIZONTAL

SLIDER
315
655
407
688
Deadline-Call3
Deadline-Call3
0
112
30
1
1
NIL
HORIZONTAL

SLIDER
315
700
407
733
Deadline-Call4
Deadline-Call4
0
112
42
1
1
NIL
HORIZONTAL

SLIDER
315
745
407
778
Deadline-Call5
Deadline-Call5
0
112
54
1
1
NIL
HORIZONTAL

SLIDER
315
790
407
823
Deadline-Call6
Deadline-Call6
0
112
66
1
1
NIL
HORIZONTAL

INPUTBOX
925
85
1135
145
Model-version
1.0 (07.2015)
1
0
String

INPUTBOX
925
145
1135
205
Experiment-name
NIL
1
0
String

MONITOR
1150
460
1285
505
Thematic orientation
[call-themes] of the-current-call
17
1
11

MONITOR
1150
550
1285
595
Capabilities range
[call-range] of the-current-call
17
1
11

SLIDER
315
40
407
73
Cutoff-point
Cutoff-point
0
6
0
1
1
NIL
HORIZONTAL

SWITCH
220
840
313
873
Repeat-last-call?
Repeat-last-call?
1
1
-1000

SLIDER
600
655
692
688
Range-Call3
Range-Call3
0
100
35
1
1
NIL
HORIZONTAL

SLIDER
600
700
692
733
Range-Call4
Range-Call4
0
100
35
1
1
NIL
HORIZONTAL

SLIDER
600
745
692
778
Range-Call5
Range-Call5
0
100
35
1
1
NIL
HORIZONTAL

SLIDER
600
790
692
823
Range-Call6
Range-Call6
0
100
35
1
1
NIL
HORIZONTAL

SLIDER
505
250
597
283
Duration-stdev-CIP
Duration-stdev-CIP
0
100
5.1
1
1
NIL
HORIZONTAL

TEXTBOX
175
190
200
208
CSO
11
0.0
1

SLIDER
220
180
312
213
Perc-CSO
Perc-CSO
0
100
9
1
1
NIL
HORIZONTAL

SLIDER
315
180
407
213
Size-CSO
Size-CSO
0
50
10
1
1
NIL
HORIZONTAL

MONITOR
2227
35
2291
80
CSO
count participants with [my-type = \"cso\"]
17
1
11

MONITOR
2227
80
2291
125
CSO in net
count participants with [(my-type = \"cso\") and (any? my-network)]
17
1
11

SLIDER
505
315
597
348
CSO-min-CIP
CSO-min-CIP
0
100
1
1
1
NIL
HORIZONTAL

TEXTBOX
540
295
570
313
CSO
11
0.0
1

MONITOR
2229
823
2292
868
CSO (avg. K)
round (10 * mean kenes-length-CSO) / 10
17
1
11

MONITOR
2229
867
2292
912
CSO (med. K)
round (10 * median kenes-length-CSO) / 10
17
1
11

PLOT
1360
605
1570
755
Participation (RRI Score)
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"" 5.0 1 -2674135 true "" ""

PLOT
1360
755
1570
905
Responsiveness (RRI Score)
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"" 5.0 1 -2674135 true "" ""

SLIDER
505
380
597
413
RRI-balance-CIP
RRI-balance-CIP
0
100
50
1
1
NIL
HORIZONTAL

PLOT
1150
605
1360
755
Anticipation (RRI Score)
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"" 5.0 1 -2674135 true "" ""

PLOT
1150
755
1360
905
Reflexivity (RRI Score)
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"" 5.0 1 -2674135 true "" ""

PLOT
1800
605
2010
755
Total RRI Score
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"" 5.0 1 -2674135 true "" ""

PLOT
1800
755
2010
905
Total SCI Score
Score
Frequency
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"" 5.0 1 -13791810 true "" ""

CHOOSER
220
380
312
425
RRI-criteria-CIP
RRI-criteria-CIP
"none" "all"
1

SLIDER
410
380
502
413
SCI-min-CIP
SCI-min-CIP
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
315
380
407
413
RRI-min-CIP
RRI-min-CIP
0
100
10
1
1
NIL
HORIZONTAL

SWITCH
600
830
693
863
Special-caps?
Special-caps?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

SKIN (Simulating Knowledge Dynamics in Innovation Networks) is a multi-agent model of innovation networks in knowledge-intensive industries grounded in empirical research and theoretical frameworks from innovation economics and economic sociology. The agents represent innovative firms who try to sell their innovations to other agents and end users but who also have to buy raw materials or more sophisticated inputs from other agents (or material suppliers) in order to produce their outputs. This basic model of a market is extended with a representation of the knowledge dynamics in and between the firms. Each firm tries to improve its innovation performance and its sales by improving its knowledge base through adaptation to user needs, incremental or radical learning, and co-operation and networking with other agents.

## HOW IT WORKS

The agents

The individual knowledge base of a SKIN agent, its kene, contains a number of �units of knowledge�. Each unit in a kene is represented as a triple consisting of a firm�s capability C in a scientific, technological or business domain, its ability A to perform a certain application in this field, and the expertise level E the firm has achieved with respect to this ability. The units of knowledge in the kenes of the agents can be used to describe their virtual knowledge bases.

The market

Because actors in empirical innovation networks of knowledge-intensive industries interact on both the knowledge and the market levels, there needs to be a representation of market dynamics in the SKIN model. Agents are therefore characterised by their capital stock. Each firm, when it is set up, has a stock of initial capital. It needs this capital to produce for the market and to finance its R&D expenditures; it can increase its capital by selling products. The amount of capital owned by a firm is used as a measure of its size and additionally influences the amount of knowledge (measured by the number of triples in its kene) that it can maintain.  Most firms are initially given the same starting capital allocation, but in order to model differences in firm size, a few randomly chosen firms can be allocated extra capital.

Firms apply their knowledge to create innovative products that have a chance of being successful in the market. The special focus of a firm, its potential innovation, is called an innovation hypothesis. In the model, the innovation hypothesis (IH) is derived from a subset of the firm�s kene triples.

The underlying idea for an innovation, modelled by the innovation hypothesis, is the source an agent uses for its attempts to make profits in the market. Because of the fundamental uncertainty of innovation, there is no simple relationship between the innovation hypothesis and product development. To represent this uncertainty,  the innovation hypothesis is transformed into a product through a mapping procedure where the capabilities of the innovation hypothesis are used to compute an index number that represents the product. The particular transformation procedure applied allows the same product to result from different kenes.

A firm�s product, P, is generated from its innovation hypothesis as



P = Sum (capability * ability) mod N

where N is a large constant and represents the notional total number of possible different products that could be present in the market).

A product has a certain quality, which is also computed from the innovation hypothesis in a similar way, by multiplying the abilities and the expertise levels for each triple in the innovation hypothesis and normalising the result. Whereas the abilities used to design a product can be used as a proxy for its product characteristics, the expertise of the applied abilities is an indicator of the potential product quality.

In order to realise the product, the agent needs some materials. These can either come from outside the sector (�raw materials�) or from other firms, which generated them as their products. Which materials are needed is again determined by the underlying innovation hypothesis: the kind of material required for an input is obtained by selecting subsets from the innovation hypotheses and applying the standard mapping function.

These inputs are chosen so that each is different and differs from the firm�s own product. In order to be able to engage in production, all the inputs need to be obtainable on the market, i.e. provided by other firms or available as raw materials. If the inputs are not available, the firm is not able to produce and has to give up this attempt to innovate. If there is more than one supplier for a certain input, the agent will choose the one at the cheapest price and, if there are several similar offers, the one with the highest quality.

If the firm can go into production, it has to find a price for its product, taking into account the input prices it is paying and a possible profit margin. While the simulation starts with product prices set at random, as the simulation proceeds a price adjustment mechanism following a standard mark-up pricing model increases the selling price if there is much demand, and reduces it (but no lower than the total cost of production) if there are no customers.  Some products are considered to be destined for the �end-user� and are sold to customers outside the sector: there is always a demand for such end-user products provided that they are offered at or below a fixed end-user price. A firm buys the requested inputs from its suppliers using its capital to do so, produces its output and puts it on the market for others to purchase. Using the price adjustment mechanism, agents are able to adapt their prices to demand and in doing so learn by feedback.

In making a product, an agent applies the knowledge in its innovation hypothesis and this increases its expertise in this area. This is the way that learning by doing/using is modelled. The expertise levels of the triples in the innovation hypothesis are increased and the expertise levels of the other triples are decremented. Expertise in unused triples in the kene is eventually lost and the triples are then deleted from the kene; the corresponding abilities are �forgotten�.

Thus, in trying to be successful on the market, firms are dependent on their innovation hypothesis, i.e. on their kene. If a product does not meet any demand, the firm has to adapt its knowledge in order to produce something else for which there are customers. A firm has several ways of improving its performance, either alone or in co-operation, and in either an incremental or a more radical fashion.

Learning and co-operation: improving innovation performance

In the SKIN model, firms may engage in single- and double-loop learning activities. Firm agents can:
*	use their capabilities (learning by doing/using) and learn to estimate their success via feedback from markets and clients (learning by feedback) as already mentioned above and/or
*	improve their own knowledge incrementally when the feedback is not satisfactory in order to adapt to changing technological and/or economic standards (adaptation learning, incremental learning).

If a firm�s previous innovation has been successful, i.e. it has found buyers, the firm will continue selling the same product in the next round, possibly at a different price depending on the demand it has experienced. However, if there were no sales, it considers that it is time for change. If the firm still has enough capital, it will carry out �incremental� research (R&D in the firm�s labs). Performing incremental research means that a firm tries to improve its product by altering one of the abilities chosen from the triples in its innovation hypothesis, while sticking to its focal capabilities. The ability in each triple is considered to be a point in the respective capability�s action space. To move in the action space means to go up or down by an increment, thus allowing for two possible �research directions�.

Alternatively, firms can radically change their capabilities in order to meet completely different client requirements (innovative learning, radical learning). A SKIN firm agent under serious pressure and in danger of becoming bankrupt, will turn to more radical measures, by exploring a completely different area of market opportunities. In the model, an agent under financial pressure turns to a new innovation hypothesis after first �inventing� a new capability for its kene. This is done by randomly replacing a capability in the kene with a new one and then generating a new innovation hypothesis.

An agent in the model may consider partnerships (alliances, joint ventures etc.) in order to exploit external knowledge sources. The decision whether and with whom to co-operate is based on the mutual observations of the firms, which estimate the chances and requirements coming from competitors, possible and past partners, and clients.  In the SKIN model, a marketing feature provides the information that a firm can gather about other agents: to advertise its product, a firm publishes the capabilities used in its innovation hypothesis. Those capabilities not included in its innovation hypothesis and thus in its product are not visible externally and cannot be used to select the firm as a partner. The firm�s �advertisement� is then the basis for decisions by other firms to form or reject co-operative arrangements.

In experimenting with the model, one can choose between two different partner search strategies, both of which compare the firm�s own capabilities as used in its innovation hypothesis and the possible partner�s capabilities as seen in its advertisement. Applying the conservative strategy, a firm will be attracted to a partner that has similar capabilities; using a progressive strategy the attraction is based on the difference between the capability sets.

To find a partner, the firm will look at previous partners first, then at its suppliers, customers and finally at all others. If there is a firm sufficiently attractive according to the chosen search strategy (i.e. with attractiveness above the �attractiveness threshold�), it will stop its search and offer a partnership. If the potential partner wishes to return the partnership offer, the partnership is set up.

The model assumes that partners learn only about the knowledge being actively used by the other agent. Thus, to learn from a partner, a firm will add the triples of the partner�s innovation hypothesis to its own. For capabilities that are new to it, the expertise levels of the triples taken from the partner are reduced in order to mirror the difficulty of integrating external knowledge as stated in empirical learning research.  For partner�s capabilities that are already known to it, if the partner has a higher expertise level, the firm will drop its own triple in favour of the partner�s one; if the expertise level of a similar triple is lower, the firm will stick to its own version. Once the knowledge transfer has been completed, each firm continues to produce its own product, possibly with greater expertise as a result of acquiring skills from its partner.

If the firm�s last innovation was successful, i.e. the value of its profit in the previous round was above a threshold, and the firm has some partners at hand, it can initiate the formation of a network. This can increase its profits because the network will try to create innovations as an autonomous agent in addition to those created by its members and will distribute any rewards back to its members who, in the meantime, can continue with their own attempts, thus providing a double chance for profits. Networks are �normal� agents, i.e. they get the same amount of initial capital as other firms and can engage in all the activities available to other firms. The kene of a network is the union of the triples from the innovation hypotheses of all its participants. If a network is successful it will distribute any earnings above the amount of the initial capital to its members; if it fails and becomes bankrupt, it will be dissolved.

Start-ups

If a sector is successful, new firms will be attracted into it. This is modelled by adding a new firm to the population when any existing firm makes a substantial profit. The new firm is a clone of the successful firm, but with its kene triples restricted to those in the successful firm�s advertisement and these having a low expertise level. This models a new firm copying the characteristics of those seen to be successful in the market. As with all firms, the kene may also be restricted because the initial capital of a start-up is limited and may not be sufficient to support the copying of the whole of the successful firm�s innovation hypothesis.



## REFERENCES

More information about SKIN and research based on it can be found at: http://cress.soc.surrey.ac.uk/skin/home

The following papers describe the model and how it has been used by its originators:

Gilbert, Nigel, Pyka, Andreas, & Ahrweiler, Petra. (2001b). Innovation networks - a simulation approach. Journal of Artificial Societies and Social Simulation, 4(3)8, <http://www.soc.surrey.ac.uk/JASSS/4/3/8.html>.

Vaux, Janet, & Gilbert, Nigel. (2003). Innovation networks by design: The case of the mobile VCE. In A. Pyka & G. K�ppers (Eds.), Innovation networks: Theory and practice. Cheltenham: Edward Elgar.

Pyka, Andreas, Gilbert, Nigel, & Ahrweiler, Petra. (2003). Simulating innovation networks. In A. Pyka & G. K�ppers; (Eds.), Innovation networks: Theory and practice. Cheltenham: Edward Elgar.

Ahrweiler, Petra, Pyka, Andreas, & Gilbert, Nigel. (2004). Simulating knowledge dynamics in innovation networks (SKIN). In R. Leombruni & M. Richiardi (Eds.),Industry and labor dynamics: The agent-based computational economics approach. Singapore: World Scientific Press.

Ahrweiler, Petra, Pyka, Andreas & Gilbert, Nigel. (2004), Die Simulation von Lernen in Innovationsnetzwerken, in: Michael Florian und Frank Hillebrandt (eds.): Adaption und Lernen in und von Organisationen. VS-Verlag f�r Sozialwissenschaften, Opladen 2004, 165-186.

Pyka, A. (2006), Modelling Qualitative Development. Agent Based Approaches in Economics, in: Rennard, J.-P. (Hrsg.), Handbook of Research on Nature Inspired Computing for Economy and Management, Idea Group Inc., Hershey, USA, 211-224.

Gilbert, Nigel, Ahrweiler, Petra, & Pyka, Andreas. (2007). Learning in innovation networks: Some simulation experiments. Physica A, 378, 100-109.

Pyka, Andreas, Gilbert, Nigel, & Ahrweiler, Petra. (2007). Simulating knowledge-generation and distribution processes in innovation collaborations and networks. Cybernetics and Systems, 38 (7), 667-693.

Pyka, Andreas, Gilbert, Nigel & Petra Ahrweiler (2009), Agent-Based Modelling of Innovation Networks � The Fairytale of Spillover, in: Pyka, A. and Scharnhorst, A. (eds.), Innovation Networks � New Approaches in Modelling and Analyzing, Springer: Complexity, Heidelberg and New York, 101-126.

Gilbert, N., P. Ahrweiler and A. Pyka (2010): Learning in Innovation Networks: some Simulation Experiments. In P. Ahrweiler, (ed.) : Innovation in complex social systems. London: Routledge (Reprint from Physica A, 2007), pp. 235-249.

Scholz, R., T. Nokkala, P. Ahrweiler, A. Pyka and N. Gilbert (2010): The agent-based Nemo Model (SKEIN) � simulating European Framework Programmes. In P. Ahrweiler (ed.): Innovation in complex social systems. London: Routledge, pp. 300-314.

Ahrweiler, P., A. Pyka and N. Gilbert (forthcoming): A new Model for University-Industry Links in knowledge-based Economies. Journal of Product Innovation Management.

Ahrweiler, P., N. Gilbert and A. Pyka (2010): Agency and Structure. A social simulation of knowledge-intensive Industries. Computational and Mathematical Organization Theory (forthcoming).

## CREDITS

To cite the SKIN model please use the following acknowledgement:

Gilbert, Nigel, Ahrweiler, Petra and Pyka, Andreas (2010) The SKIN (Simulating Knowledge Dynamics in Innovation Networks) model.  University of Surrey, University College Dublin and University of Hohenheim.

Copyright 2003 - 2010 Nigel Gilbert, Petra Ahrweiler and Andreas Pyka. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed: a) this copyright notice is included. b) this model will not be redistributed for profit without permission and c) the requirements of the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License <http://creativecommons.org/licenses/by-nc-sa/3.0/> are complied with.

The authors gratefully acknowldge funding during the course of development of the model from the European Commission, DAAD, and the British Council.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7500403 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
Polygon -16777216 true false 115 70 129 74 128 223 114 224
Polygon -16777216 true false 89 67 74 71 74 224 89 225 89 67
Polygon -16777216 true false 43 91 31 106 31 195 45 211
Line -1 false 200 144 213 70
Line -1 false 213 70 213 45
Line -1 false 214 45 203 26
Line -1 false 204 26 185 22
Line -1 false 185 22 170 25
Line -1 false 169 26 159 37
Line -1 false 159 37 156 55
Line -1 false 157 55 199 143
Line -1 false 200 141 162 227
Line -1 false 162 227 163 241
Line -1 false 163 241 171 249
Line -1 false 171 249 190 254
Line -1 false 192 253 203 248
Line -1 false 205 249 218 235
Line -1 false 218 235 200 144

bird1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

directed line
true
0
Line -7500403 true 150 0 150 300
Circle -7500403 true true 135 16 31

factory
true
0
Polygon -7500403 true true 1 152 2 296 299 296 299 3 264 3 265 91 152 2 2 119

line
true
0
Line -7500403 true 150 0 150 300

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Small Sim no RRI" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="120"/>
    <enumeratedValueSet variable="Experiment-name">
      <value value="&quot;Small Sim no RRI&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nMonths">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Empirical-case?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Instrument-filter">
      <value value="&quot;CIP&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Participants-settings">
      <value value="&quot;Small (no CSOs)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Instruments-settings">
      <value value="&quot;Baseline (0% RRI)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Calls-settings">
      <value value="&quot;Baseline (CIP)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Themes-settings">
      <value value="&quot;Baseline&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Other-settings">
      <value value="&quot;Baseline&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repeat-last-call?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Update-Network-Measures-interval">
      <value value="120"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Small Sim RRI" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="120"/>
    <enumeratedValueSet variable="Experiment-name">
      <value value="&quot;Small Sim RRI&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nMonths">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Empirical-case?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Instrument-filter">
      <value value="&quot;CIP&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Participants-settings">
      <value value="&quot;Small with CSOs&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Instruments-settings">
      <value value="&quot;Balanced (50% RRI)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Calls-settings">
      <value value="&quot;with special caps&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Themes-settings">
      <value value="&quot;Baseline&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Other-settings">
      <value value="&quot;Baseline&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repeat-last-call?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Update-Network-Measures-interval">
      <value value="120"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
