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
;  Requires NetLogo 4.1 from https://ccl.northwestern.edu/netlogo/download.shtml
;  To run this model, a database of FP7 projects is required, which is not open source, but may be available from the authors
;
; This code is an adaptation of the SKIN model to the study scope of
;    "Using network analysis to monitor and track effects resulting from changes
;     in policy intervention and instruments"
; See:
; Ahrweiler, P., Schilperoord, M., Pyka, A., & Gilbert, N. (2014). Testing Policy Options for Horizon 2020 with SKIN. 
;   In N. Gilbert, Ahrweiler, P., & Pyka, A. (Eds.), Simulating Knowledge Dynamics in Innovation Networks. Heidelberg / New York: SPRINGER.
;
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
; INFSO v1.0       April     2011   Adaptation of version 5 for DG INFSO study scope

extensions [array table sql]

; globals preceded by ';' below are set by sliders, not by code
globals [
; nMonths                         ; the number of months simulated
; nParticipants                   ; the number of participants
; DFI-percent                     ; the percentage of diversified firms
; SME-percent                     ; the percentage of SMEs
; big-RES-percent                 ; the percentage of big research institutes
; big-DFI-percent                 ; the percentage of big diversified firms
; min-size-consortium
  nCapabilities                   ; global number of capabilities possible
  cap-range-length-Calls          ; for setting a Call's range of capabilities (at least one of which must appear in an eligible proposal)
  min-kene-length-SMEs            ; smallest kene length
  search-depth                    ; search depth for finding partners
  max-number-of-subprojects       ; for allocation of partners to sub-projects
  min-size-of-subprojects         ; for allocation of partners to sub-projects
  max-deliverable-length
  
  ; some other globals (not parameters)
  log?                            ; switch off for more speed
  highest-proposal-nr             ; for setting proposal-nr
  the-current-call                ; for monitoring the latest call
  adj-matrix                      ; adjacency matrix
  
  ; dictionaries for getting and setting the variables of a specific Instrument or Call
  ; e.g. [duration] of table:get instruments-dict "CP"
  instruments-dict
  calls-dict
  
  ; network measures
  count-of-edges
  count-of-possible-edges
  number-of-components
  component-size
  largest-component-size
  largest-start-node
  connected?
  num-connected-pairs
  diameter
  average-path-length
  clustering-coefficient
  infinity
  
  ; some measures for projects
  project-count
  sum-of-project-sizes
  project-sizes
  
  ; cases
  the-empirical-case
]


; the instruments (CP, NoE and CSA)
breed [ instruments instrument ]

; the calls of the Commission
breed [ calls call ]

; three different populations: research institutes (including universities), diversified firms and SMEs
breed [ participants participant ]

; the research proposals with their consortia
breed [ proposals proposal ]

; the research projects with their results
breed [ projects project ]

; the research sub-projects working on a specific deliverable
breed [ subprojects subproject ]

; the cases with lists of instruments, calls, participants, etc.
breed [ cases case ]


instruments-own [
  instrument-nr
  instrument-type                 ; = "CP", "NoE" or "CSA"
  min-size-of-consortium          ; the minimum number of partners
  max-size-of-consortium          ; the maximum number of partners
  composition                     ; the composition of partners
  duration                        ; the length of the project
]

calls-own [
  call-nr
  call-type                       ; ~ instrument type
  call-id                         ; for the empirical case (e.g. "FP7-ICT-2009-4")
  call-publication-date           ; the publication date of the call
  call-deadline                   ; the deadline of the call
  call-size                       ; number of projects that will be funded
  call-capabilities               ; a range of capabilities (at least one of which must appear in an eligible proposal)
  call-orientation                ; the desired basic or applied orientation
  call-status                     ; = "open" or "closed"
  call-evaluated?                 ; has the call been evaluated?
  call-counter                    ; table for counting proposals
                                  ; e.g. table:get callCounter "initiated" ~ number-of-initiated-proposals
]

participants-own [
  my-nr
  my-type                         ; = "res", "dfi" or "sme"
  my-id                           ; for the empirical case (e.g. "100364091")
  my-name                         ; for the empirical case (e.g. "IBM ISRAEL")
  my-proposals                    ; the proposals I am currently in
  my-projects                     ; the projects I am currently in
  my-partners                     ; agentset of my current partners
  my-previous-partners            ; agentset of agents with which I have previously partnered
  my-cap-capacity                 ; the length of the kene, which is defined by the type of the participant
                                  ; but cannot be less than 5 quadruples (the capacity for SMEs)
  ; kene
  capabilities                    ; the kene of the participant, part 1
  abilities                       ; the kene of the participant, part 2
  expertises                      ; the kene of the participant, part 3
  research-directions             ; the kene of the participant, part 4
  
  ; network measures
  explored?
  distance-from-other-participants
  node-clustering-coefficient
]

proposals-own [
  proposal-nr
  proposal-type                   ; ~ instrument type
  proposal-call                   ; the call
  proposal-consortium             ; partners
  proposal-orientation            ; research orientation of the consortium
  proposal-coordinator            ; coordinator of the proposal (and project)
  proposal-status                 ; = 0 ("initiated") .. 7 ("dissolved")
  proposal-ranking-nr             ; set by the Commission
  ; kenes
  capabilities-set                ; compilation of kene quadruples of the consortium, part 1
  abilities-set                   ; compilation of kene quadruples of the consortium, part 2
  expertises-set                  ; compilation of kene quadruples of the consortium, part 3
  research-directions-set         ; compilation of kene quadruples of the consortium, part 4
]

projects-own [
  project-nr                      ; = proposal-nr
  project-type                    ; = proposal-type
  project-call                    ; = proposal-call
  project-acronym                 ; for the empirical case (e.g. "+SPACES")
  project-proposal                ; the proposal accepted by the Commission
  project-start-date              ; starting date of the project (start of the research)
  project-end-date                ; when the project is finalised
  project-consortium              ; same as proposal-consortium
  project-status                  ; = 8 ("started") .. 10 ("dissolved")
  project-subprojects             ; the sub-projects in which research is concentrated
  project-outputs                 ; the deliverables of the project
  project-successful?             ; success depends on the outputs of the subprojects
]

subprojects-own [
  subproject-nr
  subproject-deliverable          ; the current sub-project deliverable (~ innovation hypothesis)
  subproject-new-deliverable?     ; true when a new deliverable has been generated
  subproject-members              ; the sub-project members (shuffle of consortium partners)
  incr-research-direction         ; direction of changing an ability (for incremental research)
  ability-to-research             ; the ability that is being changed by incremental research
  ; kenes
  capabilities-subset             ; subset of kene quadruples of the consortium, part 1
  abilities-subset                ; subset of kene quadruples of the consortium, part 2
  expertises-subset               ; subset of kene quadruples of the consortium, part 3
  research-directions-subset      ; subset of kene quadruples of the consortium, part 4
]

cases-own [
  case-nr
  case-title
  case-description
  case-nInstruments
  case-instrument-type
  case-min-size-of-consortium
  case-max-size-of-consortium
  case-composition
  case-duration
  case-nCalls
  case-call-type
  case-call-id
  case-call-publication-date
  case-call-deadline
  case-call-size
  case-call-orientation
]


; instrument types:
;   "CP"  - Collaborative Project
;   "NOE" - Network of Excellence
;   "CSA" - Coordination and Support Action

; participant types:
;   "res" - Research Institute (including University)
;   "dfi" - Diversified Firm
;   "sme" - SME

; capabilities:
; We plan to structure the knowledge space (e.g. 800 different capabilities by allocating e.g. 100 capabilities to
; each of the eight themes which DG INFSO has defined. In order to allow the SMEs to play their special role we
; should define 10 capabilities per theme as “rare” capabilities and give these capabilities in the starting
; distribution exclusively to SMEs.

; stages:
;   1 - writing of proposal (inviting partners)
;   2 - evaluation of proposal
;   3 - creating the deliverables
;   4 - evaluation of project

; status:                      next status:                            go into stage:
;   0 - proposal initiated       to 2, if enough partners                1 - writing the proposal (inviting partners)
;   1 - proposal stopped         not enough partners
;   2 - proposal submitted       to 3 or 4, depending on evaluation      2 - evaluation of proposal (eligibility)
;   3 - proposal eligible        to 3 or 4, depending on evaluation      2 - evaluation of proposal (ranking)
;   4 - proposal ineligible
;   5 - proposal accepted        to 7
;   6 - proposal rejected        to 7
;   7 - proposal dissolved       to 8, if proposal is accepted
;   8 - project started          to 9, after duration of project         3 - creating the deliverables
;   9 - project finalised        to 10, after evaluation                 4 - evaluation of project
;  10 - project dissolved        stop. project successful?


to setup
  no-display
  clear-all
  set log? false
  
  ; set sliders according to filter on project type
  let i position filter-on-project-type ["CP" "CSA" "NOE"]
  set nParticipants item i [2872  679  337]
  set DFI-percent item i [27.37  22.24  11.28]
  set SME-percent item i [37.85  21.06  4.15]
  ;set big-RES-percent item i [0 0 0]
  ;set big-DFI-percent item i [0 0 0]
  set capability-match-threshold item i [8 7 15]
  
  set nCapabilities 800
  set cap-range-length-Calls 25
  set min-kene-length-SMEs 5
  set search-depth 20
  set max-number-of-subprojects 3
  set min-size-of-subprojects 1
  set max-deliverable-length 9
  set highest-proposal-nr 0
  set infinity 99999
  
  set project-count 0
  set sum-of-project-sizes 0
  set project-sizes []
  
  ; create a population of participants (research institutes, diversified firms, and SMEs),
  ; a set of instruments and a series of calls (to be published later)
  
  ifelse show-empirical-case? [
    create-empirical-case
    load-empirical-case
    analise-empirical-case
    initialise-instruments-case
    initialise-calls-case
  ]
  [
    initialise-participants
    ask participants [ make-kene ]
    initialise-instruments
    initialise-calls
    ask calls [ make-cap-range ]
  ]
  
  update-network-measures
  update-plots
end


;;; CASES
;;;
;;; create cases, read data, etc.
;;;


to create-empirical-case
  set the-empirical-case nobody
  create-cases 1 [
    set the-empirical-case self
    set case-nr 1
    set case-title "Empirical Case"
    set case-description "Empirical Case based on the FP7 ICT dataset provided by DG INFSO"
    hide-turtle
  ]
  ask the-empirical-case [
    initialise-case
  ]
end


to initialise-case
  set case-nInstruments 3
  set case-instrument-type ["CP" "CSA" "NOA"]
  set case-min-size-of-consortium [3 1 4]
  set case-max-size-of-consortium [37 38 51]
  set case-composition [["res" "dfi" "sme"] ["res" "dfi" "sme"] ["res" "dfi" "sme"]]
  set case-duration [36 24 48]
  ; calls
  set case-nCalls 6
  set case-call-id ["FP7-ICT-2007-1" "FP7-ICT-2007-2" "FP7-ICT-2007-3" "FP7-ICT-2009-4" "FP7-ICT-2009-5" "FP7-ICT-2009-6"]
  set case-call-type [[80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5]]
  set case-call-publication-date [1 7 13 25 31 37]
  set case-call-deadline [6 12 18 30 36 42]
  set case-call-size [[259 120 56 202 160 61] [47 24 12 50 39 11] [11 5 3 4 9 2]]
  set case-call-orientation [5 5 5 5 5 5]
end


to load-empirical-case  
  ; open database
  sql:configure "defaultconnection" [
    ["user" "root"]
    ["password" "coca"]
    ["database" "infsofp7?zeroDateTimeBehavior=convertToNull"]
  ]
  
  ; get the projects
  let filter-on-call-id "('FP7-ICT-2007-1', 'FP7-ICT-2007-2', 'FP7-ICT-2007-3', 'FP7-ICT-2009-4', 'FP7-ICT-2009-5', 'FP7-ICT-2009-6')"
  let sql-exec (word "SELECT ProjectNumber, ProjectAcronym, CallIdentifier, ProjectFundingScheme, ProjectStartDate, ProjectEndDate FROM Project WHERE CallIdentifier IN " filter-on-call-id " AND ProjectFundingScheme = '" filter-on-project-type "'")
  sql:exec-direct sql-exec
  let all-projects sql:fetch-resultset
  
  let nr 1 ; for numbering participants
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
      set project-type item 3 row          ; e.g. CP
      set project-start-date date-to-month item 4 row  ; e.g. 2010-01-01 -> 39
      set project-end-date date-to-month item 5 row    ; e.g. 2012-06-30 -> 69
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
        ; this is a new participant - create a turtle for it
        create-participants 1 [
          set my-nr nr
          set my-id item 0 project-row     ; e.g. 100364091
          set member self
          set nr nr + 1
        ]
      ]
      
      set members (turtle-set member members)
    ]
    
    ; the project consortium 
    ask the-new-project [ set project-consortium members ]
  ]
  
  ; add participant name and org. type to participant turtles
  
  ask participants [
    sql:exec-query "SELECT ParticipantShortName, OrganisationType, SMEFlag FROM Participant WHERE ParticipantID = ?" (list my-id)
    let row sql:fetch-row
    set my-name item 0 row                 ; e.g. IBM ISRAEL
    set my-type type-to-type item 1 row item 2 row  ; e.g. PRC & N -> dfi
    set my-proposals no-turtles
    set my-projects no-turtles
    set my-partners no-turtles
    set my-previous-partners no-turtles
    set capabilities []
    set abilities []
    set expertises []
    set research-directions []
  ]
end


to analise-empirical-case
  let nr-of-projects 0
  ask projects with [project-type = filter-on-project-type] [
    print (word project-acronym ", " project-type ", " count project-consortium)
    set nr-of-projects nr-of-projects + 1
  ]
  print (word "nr-of-projects " filter-on-project-type " = " nr-of-projects)
end


; convert from full date YYYY-MM-DD to month:
; 2006-11-DD -> 0, 2006-12-DD -> 1 etc.

to-report date-to-month [ the-date ]
  if not is-string? the-date [ report 0 ] ; intercept <null>
  let the-year substring the-date 0 4
  let the-month substring the-date 5 7
  let months 12 * position the-year ["2006" "2007" "2008" "2009" "2010" "2011" "2012" "2013" "2014" "2015" "2016"]
  set months months + position the-month ["01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"]
  report months - 11
end


; convert from "INFSO"-type to "SKIN"-type

to-report type-to-type [ infso-type sme-flag ]
  if infso-type = "HES" or infso-type = "REC"
    [ report "res" ]
  if infso-type = "PRC" [
    ifelse sme-flag = "Y"
      [ report "sme" ]
      [ report "dfi" ]
  ]
  report "oth"
end


;;; PARTICIPANTS
;;;
;;; initialise participants, make kenes
;;;


; make participants as empty shells, yet to filled with knowledge

to initialise-participants
  let nr 1
  let nDFI round (DFI-percent * nParticipants / 100)
  let nSME round (SME-percent * nParticipants / 100)
  let nRES nParticipants - (nDFI + nSME)
  ; research institutes (including universities)
  create-participants nRES [
    set my-nr nr
    set my-type "res"
    set my-cap-capacity 5 * min-kene-length-SMEs
    set nr nr + 1
    hide-turtle
  ]
  ; diversified firms
  create-participants nDFI [
    set my-nr nr
    set my-type "dfi"
    set my-cap-capacity 5 * min-kene-length-SMEs
    set nr nr + 1
    hide-turtle
  ]
  ; SMEs
  create-participants nSME [
    set my-nr nr
    set my-type "sme"
    set my-cap-capacity min-kene-length-SMEs
    set nr nr + 1
    hide-turtle
  ]
  ; make some of them big research institutes, with extra cap-capacity
  ask n-of round (big-RES-percent * nRES / 100) participants with [my-type = "res"] [
    set my-cap-capacity 2 * my-cap-capacity
  ]
  ; make some of them big diversified firms, with extra cap-capacity
  ask n-of round (big-DFI-percent * nDFI / 100) participants with [my-type = "dfi"] [
    set my-cap-capacity 2 * my-cap-capacity
  ]
  ask participants [ initialise-participant ]
end


; initialise all the participant's variables (except my-type and my-cap-capacity, previously set)

; Important Remark concerning the initialisation of SMEs
; ------------------------------------------------------
; We discussed the important meaning of SMEs concerning their contribution to radical research.
; New knowledge is injected into the system most often by new, small and sophisticated companies.
; Therefore, we should design SMEs with this rare knowledge. We plan to structure the knowledge
; space (e.g. 800 different capabilities by allocating e.g. 100 capabilities to each of the eight
; themes which DG INFSO has defined. In order to allow the SMEs to play their special role we
; should define 10 capabilities per theme as “rare” capabilities and give these capabilities in
; the starting distribution exclusively to SMEs.

;participant procedure
to initialise-participant
  set my-proposals no-turtles
  set my-projects no-turtles
  set my-partners no-turtles
  set my-previous-partners no-turtles
  set capabilities []
  set abilities []
  set expertises []
  set research-directions []
end


;participant procedure
to make-kene
  ; fill the capability vector with capabilities. These are integers
  ; between 1 and nCapabilities, such that no number is repeated
  while [length capabilities < my-cap-capacity] [
    let candidate-capability random nCapabilities + 1
    if not member? candidate-capability capabilities [
      set capabilities fput candidate-capability capabilities
    ]
  ]
  ; now fill the research-direction, ability and expertise vectors with real numbers randomly
  ; chosen from 0 .. <10 for abilities and integers from 1 .. 10 for expertise levels.
  ; We extend the capabilities, abilities and expertise by a research direction, which is
  ; represented by an integer between 0 and 9 (0 corresponds to a full basic research
  ; orientation; 9 corresponds to a full applied research orientation)
  while [length abilities < length capabilities] [
    set abilities fput (random-float 10.0) abilities
    set expertises fput ((random 10) + 1) expertises
    set research-directions fput (random 10) research-directions
  ]
end


;;; GO
;;;
;;; main loop, 4 Stages
;;;


to go
  if ticks = nMonths [ stop ]
  
  ifelse show-empirical-case? [
    ; Stage 1
    if log? [ log-stage1 ]
    publish-calls
    if log? [ log-calls ]
    close-calls
    
    ; Stage 2
    if log? [ log-projects ]
    
    ; Stage 3
    ask projects [
      start-project
      finalise-project
    ]
    
    ; Stage 4
    dissolve-projects
  ]
  [
    ; Stage 1 - writing of proposals (inviting partners)
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
    
    ; Stage 2 - evaluation of proposals
    if log? [ log-stage2 ]
    evaluate-calls
    if log? [ log-evaluation ]
    dissolve-proposals
    if log? [ log-projects ]
    
    ; Stage 3 - creating the deliverables
    ask projects [
      start-project
      ;do-research
      ;make-deliverables
      ;publish-outputs
      finalise-project
    ]
    
    ; Stage 4 - evaluation of projects
    ;evaluate-projects
    dissolve-projects
  ]
  
  tick
  
  update-network-measures
  update-plots
  
  ;export-network-data
  export-network-data-gml
  export-network-data-gexf
  ;export-network-data-dynamic-gexf
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
      let col4 [mean expertises-set] of ?
      set col4 round (10 * col4) / 10
      if col4 < 10 [ type " " ]
      type (word col4 " ")
      if col4 = round col4 [ type "  " ]
      ; capability match
      let col5 capability-match ?
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


;;; INSTRUMENTS & CALLS
;;;
;;; create instruments, publish new calls
;;;


;observer procedure
to initialise-instruments
  let nr 1
  set instruments-dict table:make
  create-instruments 3 [
    set instrument-nr nr
    set instrument-type item (nr - 1) ["CP" "CSA" "NOE"]
    set min-size-of-consortium item (nr - 1) [3 1 4]
    set max-size-of-consortium item (nr - 1) [37 38 51]
    set composition item (nr - 1) [["res" "dfi" "sme"] ["res" "dfi" "sme"] ["res" "dfi" "sme"]]
    set duration item (nr - 1) [36 24 48]
    
    table:put instruments-dict instrument-type self
    hide-turtle
    set nr nr + 1
  ]
end


to initialise-instruments-case
  let nr 1
  set instruments-dict table:make
  create-instruments [case-nInstruments] of the-empirical-case [
    set instrument-nr nr
    set instrument-type item (nr - 1) [case-instrument-type] of the-empirical-case
    set min-size-of-consortium item (nr - 1) [case-min-size-of-consortium] of the-empirical-case
    set max-size-of-consortium item (nr - 1) [case-max-size-of-consortium] of the-empirical-case
    set composition item (nr - 1) [case-composition] of the-empirical-case
    set duration item (nr - 1) [case-duration] of the-empirical-case
    
    table:put instruments-dict instrument-type self
    hide-turtle
    set nr nr + 1
  ]
end


; The calls of the Commission specify:
; - type of instrument (STREP etc.) -> the instrument type specifies minimum number of partners,
;   composition of partners, and the length of the project.
; - date of call (to determine the deadline for submission)
; - a range of capabilities (at least one of which must appear in an eligible proposal)
; - the number of projects that will be funded
; - the desired basic or applied orientation
;
; When a new call is published, the deadline for a proposal is six months away, i.e. the agents
; have six time steps to set up a consortium and to “write a proposal”. Or the length of research
; projects (e.g. three years) and therefore the possibilities of consortium members to improve
; and exchange knowledge is given by e.g. 36 iterations.


;observer procedure
to initialise-calls
  let nr 1
  set calls-dict table:make
  create-calls 6 [
    set call-nr nr
    set call-type item (nr - 1) [[80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5] [80 3.5 16.5]]
    set call-id nr
    set call-publication-date item (nr - 1) [1 7 13 25 31 37]
    set call-deadline item (nr - 1) [6 12 18 30 36 42]
    let i position filter-on-project-type ["CP" "CSA" "NOE"]
    let call-size-after-filter item i [[259 120 56 202 160 61] [47 24 12 50 39 11] [11 5 3 4 9 2]]
    set call-size item (nr - 1) call-size-after-filter
    set call-capabilities [] ; based on theme (100 capabilities to each of the 8 themes)
    set call-orientation item (nr - 1) [5 5 5 5 5 5]
    set call-status ""
    set call-evaluated? false
    set call-counter table:make
    
    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
end


;observer procedure
to initialise-calls-case
  let nr 1
  set calls-dict table:make
  create-calls [case-nCalls] of the-empirical-case [
    set call-nr nr
    set call-type item (nr - 1) [case-call-type] of the-empirical-case
    set call-id item (nr - 1) [case-call-id] of the-empirical-case
    set call-publication-date item (nr - 1) [case-call-publication-date] of the-empirical-case
    set call-deadline item (nr - 1) [case-call-deadline] of the-empirical-case
    let i position filter-on-project-type ["CP" "CSA" "NOE"]
    let case-call-size-after-filter item i [case-call-size] of the-empirical-case
    set call-size item (nr - 1) case-call-size-after-filter
    set call-capabilities []
    set call-orientation item (nr - 1) [case-call-orientation] of the-empirical-case
    set call-status ""
    set call-evaluated? false
    set call-counter table:make
    
    table:put calls-dict call-id self
    hide-turtle
    set nr nr + 1
  ]
end


;call procedure
to make-cap-range
  ; fill the capability vector with capabilities. These are integers
  ; between 1 and nCapabilities, such that no number is repeated
  while [length call-capabilities < cap-range-length-Calls] [
    let candidate-capability random nCapabilities + 1
    if not member? candidate-capability call-capabilities [
      set call-capabilities fput candidate-capability call-capabilities
    ]
  ]
end


;observer procedure
to publish-calls
  ask calls with [call-publication-date = ticks] [
    set call-status "open"
    set the-current-call self
  ]
end


;observer procedure
to close-calls
  ask calls with [call-deadline = ticks + 1] [ set call-status "closed" ]
end


; notify the Call about the changed status of the proposal
;
; here is an example:
; Call 1 is notified about the change that a proposal is "submitted". This procedure
; updates the table of Call 1, increasing the number of submitted proposals.
; If this is the first proposal that is submitted for the Call, the table key
; "submitted" does not exist and thus cannot be read. In this case, the new key
; is mapped to the value 1.

; proposal procedure
to notify-changed-status
  let the-updated-value 1
  let the-counter [call-counter] of proposal-call
  if (table:has-key? the-counter proposal-status)
    [ set the-updated-value (table:get the-counter proposal-status) + 1 ]
  table:put the-counter proposal-status the-updated-value
end


;;; PROPOSALS & RESEARCH CONSORTIA
;;;
;;; initiate proposals, invite partners, formulate and submit proposals
;;;


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
; (length of the kene) / (minimum length of an SME kene) – (the number of existing projects)
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
  report (length capabilities / min-kene-length-SMEs) - (count my-proposals + count my-projects) > 0
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
    ; kenes
    set capabilities-set []
    set abilities-set []
    set expertises-set []
    set research-directions-set []
    set highest-proposal-nr proposal-nr
  ]
  report the-new-proposal
end


;participant procedure
to initiate-proposal [ the-call ]
  if log? [ type (word "I am participant " my-nr " (" my-type ") (in " count my-proposals " proposals). ") ]
  ifelse room-for-another-proposal? [
    let the-new-proposal make-proposal
    if log? [ print (word "I am initiating a new proposal " [proposal-nr] of the-new-proposal ".") ]
    set my-proposals (turtle-set my-proposals the-new-proposal)
    ask the-new-proposal [
      set proposal-type filter-on-project-type
      set proposal-call the-call
      set proposal-consortium (turtle-set myself)
      set proposal-coordinator myself
      notify-changed-status
    ]
  ]
  [ if log? [ print (word "I have no 'room' for initiating a new proposal.") print "" ] ]
end


; A proposal is a compilation of kene quadruples of agents in the proposal consortium.
; - Each agent is contributing one capability to the proposal.
; - If the agent has a capability which is specified in the Call he contributes this capability.
; - If the agent possesses more than one capability outlined in the Call we randomly choose
;   one of these capabilities.
;
; The possibilities to join a proposal consortium are determined by the same rules we applied
; for the determination of project initiations. The length of the kene determines whether the
; agent has free capacities for new activities, e.g. a SME, whose kene is of minimum size
; (i.e. five quadruples) and which is already in a project or a proposal initiative has to
; reject the offer.


;participant procedure
to join [ the-proposal ]
  if log? [ type (word "I am participant " my-nr " (" my-type "). I am invited to join proposal " [proposal-nr] of the-proposal ". ") ]
  ifelse room-for-another-proposal? [
    ; randomly choose one capability to contribute
    let the-call [proposal-call] of the-proposal
    let my-relevant-capabilities intersection capabilities [call-capabilities] of the-call
    ifelse not empty? my-relevant-capabilities [
      if log? [ print "I accept." ]
      let my-capability one-of my-relevant-capabilities
      let my-location position my-capability capabilities
      ; add a kene quadruple to the proposal
      ask the-proposal [
        set capabilities-set fput my-capability capabilities-set
        set abilities-set fput (item my-location [abilities] of myself) abilities-set
        set expertises-set fput (item my-location [expertises] of myself) expertises-set
        set research-directions-set fput (item my-location [research-directions] of myself) research-directions-set
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
to find-possible-partners [ the-proposal ]
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
    while [not eligible? the-proposal and length possible-partners > 0 and nr < search-depth] [
      let a-possible-partner one-of possible-partners
      ask a-possible-partner [ join the-proposal ]
      set possible-partners remove a-possible-partner possible-partners
      if not member? a-possible-partner [proposal-consortium] of the-proposal
        [ set declined lput a-possible-partner declined ]
      set nr nr + 1
    ]
    
    ; 2nd iteration - previous partners can add their previous partners
    let previous-partners no-turtles
    ask my-previous-partners [ set previous-partners (turtle-set previous-partners my-previous-partners) ]
    set possible-partners [self] of previous-partners with [not member? self [proposal-consortium] of the-proposal]
    set possible-partners set-difference declined possible-partners
    ; the search (same as above)
    set nr 0
    while [not eligible? the-proposal and length possible-partners > 0 and nr < search-depth] [
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
  set possible-partners set-difference declined possible-partners
  ; the search (same as above)
  set nr 0
  while [not eligible? the-proposal and length possible-partners > 0 and nr < search-depth] [
    let a-possible-partner one-of possible-partners
    ask a-possible-partner [ join the-proposal ]
    set possible-partners remove a-possible-partner possible-partners
    if not member? a-possible-partner [proposal-consortium] of the-proposal
      [ set declined lput a-possible-partner declined ]
    set nr nr + 1
  ]
end


; A proposal will be submitted if at least one capability appears. Otherwise the process is
; stopped and the agents may start a new initiative.

;participant procedure
to submit-proposals
  ask my-proposals with [proposal-status = "initiated" and proposal-coordinator = myself] [
    if log? [ type (word "I am participant " [my-nr] of myself ". ") ]
    
    ifelse eligible? self
      [
        if log? [ print "I am submitting this proposal." print "" ]
        set proposal-status "submitted"
        notify-changed-status
      ]
      [
        if log? [ print "I am stopping this proposal." print "" ]
        set proposal-status "stopped"
        notify-changed-status
        dissolve-proposal
      ]
  ]
end


; reports the set intersection of the lists a and b, treated as sets

to-report intersection [ set-a set-b ]
  let set-c []
  foreach set-a [ if member? ? set-b [ set set-c fput ? set-c ] ]
  report set-c
end


; reports the set difference of lists a and b, treated as sets

to-report set-difference [ set-a set-b ]
  let set-c intersection set-a set-b
  set set-b remove-duplicates sentence set-a set-b
  foreach set-c [ if member? ? set-b [ set set-b remove ? set-b ] ]
  report set-b
end


;;; EVALUATION OF PROPOSALS
;;; 
;;; evaluate (reject or accept) and dissolve proposals
;;;


; Evaluation of Calls
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
  let the-submitted-proposals proposals with [proposal-status = "submitted" and proposal-call = myself]
  ask the-submitted-proposals [
    ifelse eligible? self
      [ set proposal-status "eligible" ]
      [ set proposal-status "ineligible" ]
    notify-changed-status
  ]
  ; look at all eligible proposals - which proposals get highest ranking?
  let the-eligible-proposals the-submitted-proposals with [proposal-status = "eligible"]
  rank the-eligible-proposals
  ask the-eligible-proposals [
    ifelse proposal-ranking-nr <= [call-size] of myself
      [ set proposal-status "accepted" ]
      [ set proposal-status "rejected" ]
    notify-changed-status
  ]
end


;observer procedure
to-report eligible? [ the-proposal ]
  let the-instrument table:get instruments-dict [proposal-type] of the-proposal
  let the-consortium [proposal-consortium] of the-proposal
  ; consortium too small or too big?
  if count the-consortium < [min-size-of-consortium] of the-instrument
    [ report false ]
  if count the-consortium > [max-size-of-consortium] of the-instrument
    [ report false ]
  ; 1st hard factor - sufficient partners with the desired research orientation
  let the-call [proposal-call] of the-proposal
  ;if mean [research-directions-set] of the-proposal < [call-orientation] of the-call
  ;  [ report false ]
  ; 2nd hard factor - at least one of the capabilities specified in the call appear in the proposal
  if capability-match the-proposal < capability-match-threshold
    [ report false ]
  ; ok for both factors
  report true
end


;observer procedure
to-report capability-match [ the-proposal ]
  let the-call [proposal-call] of the-proposal
  report length intersection [capabilities-set] of the-proposal [call-capabilities] of the-call
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
to rank [ the-eligible-proposals ]
  ; 1st ranking order - average expertise level of the proposals
  ; 2nd ranking order - number of capabilities specified in the call which are in the proposal
  ; 3rd ranking order - randomly decide on the ranking
  set the-eligible-proposals sort-by [ranking-comparator? ?1 ?2] the-eligible-proposals
  let nr 1
  foreach the-eligible-proposals [
    ask ? [
      set proposal-ranking-nr nr
      set nr nr + 1
    ]
  ]
end


; reporter for the ranking the eligible proposals.
; Two proposals are being compared. Reporter should be true if ?1 comes strictly before ?2 in the desired
; sort order, and false otherwise

to-report ranking-comparator? [ a-proposal another-proposal ]
  if [mean expertises-set] of a-proposal > [mean expertises-set] of another-proposal [ report true ]
  if [mean expertises-set] of a-proposal = [mean expertises-set] of another-proposal
    [
      if capability-match a-proposal > capability-match another-proposal [ report true ]
      if capability-match a-proposal = capability-match another-proposal [ report (random 2) = 1 ]
    ]
  report false
end


; Proposal consortia which are not successful are dissolved.
; Proposal consortia which are successful become project consortia.

;observer procedure
to dissolve-proposals
  ; successful consortia -> project consortia
  ask proposals with [proposal-status = "accepted"] [ make-project dissolve-proposal ]
  ; dissolve not successful consortia
  ask proposals with [proposal-status = "ineligible"] [ dissolve-proposal ]
  ask proposals with [proposal-status = "rejected"] [ dissolve-proposal ]
end


; make the project based on the proposal

;proposal procedure
to make-project
  let the-instrument table:get instruments-dict proposal-type
  let the-consortium proposal-consortium
  let the-new-project nobody
  hatch-projects 1 [
    set the-new-project self
    set project-nr [proposal-nr] of myself
    set project-type [proposal-type] of myself
    set project-call [proposal-call] of myself ; TO DO how to do this?
    set project-proposal myself
    set project-start-date ticks + 9 ; project starts 9 months after call is closed
    ; end-date depends on instrument type
    set project-end-date project-start-date + [duration] of the-instrument
    set project-consortium (turtle-set the-consortium)
    set project-subprojects no-turtles
    set project-outputs 0
    set project-successful? false
    set project-status ""
  ]
  if log? [ print (word "New project " [project-nr] of the-new-project " of type " [project-type] of the-new-project ".") ]
end


;proposal procedure
to dissolve-proposal
  let the-proposal self
  ask proposal-consortium [ set my-proposals my-proposals with [self != the-proposal] ]
  die
end


;;; RESEARCH PROJECTS & DELIVERABLES
;;;
;;; start projects, do research, make deliverables
;;;


;project procedure
to start-project
  if project-start-date = ticks [
    set project-status "started"
    if log? [ print (word "Project " project-nr " has now started.") ]
    
    ; consortium members now become collaboration partners
    let the-consortium project-consortium
    ask the-consortium [
      if log? [ print (word "I am participant " my-nr " (" my-type "). I am a consortium partner.") ]
      ;type (word "count my-projects before: " count my-projects)
      ;print (word "   count my-partners before: " count my-partners)
      set my-projects (turtle-set my-projects self) ; TO DO is this right?
      set my-partners (turtle-set my-partners the-consortium with [self != myself])
      ;type (word "count my-projects after:  " count my-projects)
      ;print (word "   count my-partners after:  " count my-partners)
    ]
    if log? [ print "" ]
    
    ;allocate-to-subprojects
  ]
end


;project procedure
to finalise-project
  if project-end-date = ticks [ set project-status "finalised" ]
end


; The research in the projects follows the ideas of SKEIN. Agents in project consortia are randomly
; allocated to sub-projects and combine their kenes. Ever three month they produce an output (deliverable)
; which can be a working paper, a journal article or a patent. During the length of the project they can
; improve their results.
;
; The research undertaken in projects is incremental research (abilities are substituted, expertise
; levels are increased). The potential of a radical innovation is determined only when the proposal is put
; together in the sense that new capability combinations can appear in consortia. SMEs are important
; candidates for contributing new capabilities (how is that?) and therefore increase the likelihood for
; radical innovation.


; Randomly allocate agents in project to sub-projects and combine their kenes.

;project procedure
to allocate-to-subprojects
  let possible-members shuffle [self] of project-consortium
  ifelse length possible-members < 2 * min-size-of-subprojects [
    ; very small consortium - only 1 sub-project
    make-subprojects 1
    foreach possible-members [
      ; add all members to the 1 sub-project
      ask ? [ signup one-of project-subprojects ]
    ]
  ]
  [ ; more than 1 sub-project
    let nr min list max-number-of-subprojects int (length possible-members / min-size-of-subprojects)
    make-subprojects nr
    ask project-subprojects [
      foreach n-of min-size-of-subprojects possible-members [
        ; add randomly the minimal number of members per sub-project
        ask ? [ signup myself ]
        set possible-members remove ? possible-members
      ]
    ]
    foreach possible-members [
      ; add randomly the remaining members to sub-projects
      ask ? [ signup one-of project-subprojects ]
    ]
  ]
end


;project procedure
to make-subprojects [ the-number-of-subprojects ]
  let the-new-subproject nobody
  set project-subprojects nobody
  repeat the-number-of-subprojects [
    hatch-subprojects 1 [
      set the-new-subproject self
      set subproject-deliverable []
      set subproject-new-deliverable? false
      set subproject-members []
      set incr-research-direction "random"
    ]
    set project-subprojects (turtle-set project-subprojects the-new-subproject)
  ]
end


; participant procedure
to signup [ the-subproject ]
  ask the-subproject [ set subproject-members lput myself subproject-members ]
  ; commit certain kenes (subset of quadruples) to the sub-project
end


;project procedure
to do-research
  if project-status = "started" [ ask project-subprojects [ do-incremental-research ] ]
end


; do incremental research (abilities are substituted, expertise levels are increased)

;sub-project procedure
to do-incremental-research
  if incr-research-direction = "random" [
    set ability-to-research random length subproject-deliverable
    ifelse (random 2) = 1
      [ set incr-research-direction "up" ]
      [ set incr-research-direction "down" ]
  ]
  let new-ability item ability-to-research abilities
  ifelse incr-research-direction = "up"
    [ set new-ability new-ability + (new-ability / item ability-to-research capabilities) ]
    [ set new-ability new-ability - (new-ability / item ability-to-research capabilities) ]
  if new-ability <= 0  [ set new-ability 0   set incr-research-direction "random" ]
  if new-ability > 10  [ set new-ability 10  set incr-research-direction "random" ]
  set abilities replace-item ability-to-research abilities new-ability
  set subproject-new-deliverable? true
end


; raise the expertise level by one (up to a maximum of 10) for capabilities that
; are used in the sub-project, and decrease by one for capabilities that are not.
; If an expertise level has dropped to zero, the capability is forgotten.

;participant procedure
to adjust-expertise
  let location 0
  while [location < length capabilities] [
    let expertise item location expertises
    ifelse member? location subproject-deliverable
      [ ; capability has been used - increase expertise if possible
        if expertise < 10 [ set expertises replace-item location expertises (expertise + 1) ]
      ]
      [ ; capability has not been used - decrease expertise and drop capability if expertise has fallen to zero
        ifelse expertise > 0
        [ set expertises replace-item location expertises (expertise - 1) ]
        [ forget-capability location set location location - 1]
      ]
    set location location + 1
  ]
end


; remove the capability, ability, expertise at the given location of the kene.  
; Warning; all hell will break loose if the capability that is being forgotten is included 
; in the innovation hypothesis (but no test is done to check this).
; Although the kene is changed, the deliverable and the product are not (since
; the forgotten capability is not in the deliverable, this doesn't matter)

;participant procedure
to forget-capability [location ]
  set capabilities remove-item location capabilities
  set abilities remove-item location abilities
  set expertises remove-item location expertises
  adjust-deliverable location
end


; reduce the values (which are indices into the kene) in the deliverable to
; account for the removal of a capability. Reduce all indices above 'location' by one.

;participant procedure
to adjust-deliverable [ location ]
  let elem 0
  let i 0
  while [ i < length subproject-deliverable ] [
    set elem item i subproject-deliverable
    if elem > location [ set subproject-deliverable replace-item i subproject-deliverable (elem - 1 ) ] 
    set i i + 1
  ]
end


; obtain capabilities from partners. The capabilities that are learned are those 
; from the partners' innovation hypothesis.

;participant procedure
to learn-from-partners
  ask my-partners [ merge-capabilities myself ]
  make-deliverable
end


;participant procedure
to merge-capabilities [ other-participant ]
  add-capabilities other-participant
  ask other-participant [ add-capabilities myself ]
end


; for each capability in the deliverable, if it is new to me, 
; add it (and its ability) to my kene (if I have sufficient capacity), and make   
; the expertise level 1 less. For each capability that is not new, if the other's  
; expertise level is greater than mine, adopt its ability and expertise level, 
; otherwise do nothing.

;participant procedure
to add-capabilities [ other-participant ]
  let my-position 0
  foreach subproject-deliverable [
    let capability item ? [capabilities] of other-participant
    ifelse member? capability capabilities [
      ;  capability already known to me
      set my-position position capability capabilities
      if item my-position expertises < item ? [expertises] of other-participant [
        set expertises replace-item my-position expertises item ? [expertises] of other-participant 
        set abilities replace-item my-position abilities item ? [abilities] of other-participant
      ]
    ]
    [
    ; capability is new to me; adopt it if I have 'room'
    if length capabilities < my-cap-capacity [
      set capabilities sentence capabilities capability
      set abilities sentence abilities item ? [abilities] of other-participant
      let other-expertise (item ? [expertises] of other-participant) - 1
      ; if other-expertise is 1, it is immediately forgotten by adjust-expertise
      if other-expertise < 2 [set other-expertise 2 ]
      set expertises sentence expertises other-expertise 
    ]
  ]
]
end


;project procedure
to make-deliverables
  ; every three months the sub-projects produce an output (deliverable)
  ; can be a working paper, a journal article or a patent
  let time-on-project ticks - project-start-date
  if (time-on-project > 0) and ((time-on-project mod 3) = 0) [ ask project-subprojects [ make-deliverable ] ]
  ask project-subprojects [ make-deliverable ]
end


; a deliverable is a vector of locations in the project kene. So, for example, a deliverable
; might be [1 3 4 7], meaning the second (counting from 0 as the first), fourth, fifth
; and eighth quadruple in the kene. The deliverable cannot be longer than the length of the kene,
; nor shorter than 2, but is of random length between these limits.

;subproject procedure
to make-deliverable
  print "subproject makes a new deliverable"
  set subproject-deliverable []
  let location 0
  let kene-length length capabilities
  let deliverable-length min (list ((random max-deliverable-length) + 2) kene-length)
  while [ deliverable-length > 0 ] [
    set location random kene-length
    if not member? location subproject-deliverable [
      set subproject-deliverable fput location subproject-deliverable
      set deliverable-length deliverable-length - 1
    ]
  ]
  ; reorder the elements of the deliverable in numeric ascending order
  set subproject-deliverable sort subproject-deliverable
  
  ; initialise incremental research values, since this is a new deliverable, and
  ; previous research will have been using a different deliverable
  set incr-research-direction "random"
  set subproject-new-deliverable? true
end


;project procedure
to publish-outputs
  let the-new-outputs 0
  ask subprojects [
    if (subproject-new-deliverable?) [
      set the-new-outputs the-new-outputs + 1
      set subproject-new-deliverable? false
    ]
  ]
  set project-outputs project-outputs + the-new-outputs
end


; the expertise levels of the capabilities used for the deliverables are increasing at each iteration.
; Capabilities of deliverables are exchanged among partners (i.e. knowledge transfer in projects, but
; they have to start with low expertise).



;;; EVALUATION OF PROJECTS
;;; 
;;; evaluate (successful or not) and dissolve projects
;;;


; at the end of the project all results are delivered to the Commission. And the partners start new
; proposal consortia etc. Only in the case the results are below a certain threshold the Commission puts
; the partners of the project on a black list. However, so far we have not considered to implement any
; consequences from this.


;observer procedure
to evaluate-projects
end


;observer procedure
to dissolve-projects
  ask projects with [project-status = "finalised"] [ dissolve-project ]
end


;project procedure
to dissolve-project
  let the-consortium project-consortium
  ask the-consortium [
    ; remove the project from my projects list
    set my-projects my-projects with [self != myself]
    ; add the consortium partners to my list of previous partners
    set my-previous-partners (turtle-set my-previous-partners the-consortium with [self != myself])
    ; rebuild my list of partners
    rebuild-partners-list
  ]
  set project-count project-count + 1
  set sum-of-project-sizes sum-of-project-sizes + count the-consortium
  set project-sizes lput count the-consortium project-sizes
  die
end


; participant procedure
to rebuild-partners-list
  set my-partners no-turtles
  foreach [self] of my-projects with [project-status = "started"] [
    let the-consortium [project-consortium] of ?
    set my-partners (turtle-set my-partners the-consortium with [self != myself])
  ]
end


;;; ADMINISTRATION
;;;
;;;


; some final tidying up at the end of every round

;observer procedure
to do-admin
end


;;; DISPLAY
;;;
;;; display some plots


; TO DO - develop indicators for (sub-)project deliverables and success

;observer procedure
to update-plots
  set-current-plot "Proposals"
  set-current-plot-pen "CP"
  plot count proposals with [proposal-type = "CP"]
  set-current-plot-pen "NOE"
  plot count proposals with [proposal-type = "NOE"]
  set-current-plot-pen "CSA"
  plot count proposals with [proposal-type = "CSA"]
  
  set-current-plot "Projects"
  set-current-plot-pen "CP"
  plot count projects with [project-type = "CP" and project-status = "started"]
  set-current-plot-pen "NOE"
  plot count projects with [project-type = "NOE" and project-status = "started"]
  set-current-plot-pen "CSA"
  plot count projects with [project-type = "CSA" and project-status = "started"]
  
  set-current-plot "Project Outputs"
  set-current-plot-pen "Project count"
  plot project-count
  
  set-current-plot "Participation in Proposals"
  set-current-plot-pen "Number of proposals"
  histogram [count my-proposals] of participants
  
  set-current-plot "Participation in Projects"
  set-current-plot-pen "Number of projects"
  histogram [count my-projects] of participants
  
  set-current-plot "Partners"
  ;set-current-plot-pen "Number of partners"
  ;histogram [count my-partners] of participants
  set-current-plot-pen "Number of previous partners"
  histogram [count my-previous-partners] of participants
  
  set-current-plot "Proposal Size (Distribution)"
  set-current-plot-pen "Size of proposals"
  histogram [count proposal-consortium] of proposals
  
  set-current-plot "Project Size (Distribution)"
  set-current-plot-pen "Size of projects"
  ;histogram [count project-consortium] of projects with [project-status = "started"]
  histogram project-sizes
  
  ;if any? proposals [ plot-degree-distribution "proposals" ]
  ;if any? projects with [project-status = "started"] [ plot-degree-distribution "projects" ]
  if length project-sizes > 0 [ plot-degree-distribution "projects" ]
  
  set-current-plot "Average Expertise Level"
  set-current-plot-pen "Mean level of expertise"
  histogram [mean expertises-set] of proposals
  set-current-plot "Capability Match"
  set-current-plot-pen "Capability match"
  histogram [capability-match self] of proposals
  
  set-current-plot "Network Density"
  set-current-plot-pen "Network density"
  plot count-of-edges / (count participants * (count participants - 1) / 2)
  
  set-current-plot "Number of Components"
  set-current-plot-pen "Number of components"
  plot number-of-components
  
  set-current-plot "Size of Largest Component"
  set-current-plot-pen "Size of largest component"
  plot largest-component-size
  
  set-current-plot "Average Degree"
  set-current-plot-pen "Average degree"
  plot 2 * count-of-edges / count participants
  
  set-current-plot "Average Distance"
  set-current-plot-pen "Average path length"
  plot average-path-length
  
  set-current-plot "Clustering"
  set-current-plot-pen "Clustering coefficient"
  plot clustering-coefficient
end


;
; plot log(number of participants) by log(frequency of projects with that number of participants)
; at the present moment of time, plus a regression line
;

to plot-degree-distribution [ the-type-of-networks ]
  if the-type-of-networks = "proposals" [ set-current-plot "Proposal Size (Regression)" ]
  if the-type-of-networks = "projects" [ set-current-plot "Project Size (Regression)" ]
  clear-plot  ;; erase what we plotted before
  set-plot-pen-color black
  set-plot-pen-mode 2 ;; plot points
  let max-degree 0
  if the-type-of-networks = "proposals" [ set max-degree max [count proposal-consortium] of proposals ]
  ;if the-type-of-networks = "projects" [ set max-degree max [count project-consortium] of projects with [project-status = "started"] ]
  if the-type-of-networks = "projects" [ set max-degree max project-sizes ]
  let degree 1 ; only include nodes with at least one link
  let sumx 0 ; for regression line
  let sumy 0
  let sumxy 0
  let sumxx 0
  let sumyy 0
  let n 0
  while [degree <= max-degree]
  [
    let matches 0
    if the-type-of-networks = "proposals" [ set matches proposals with [count proposal-consortium = degree] ]
    ;if the-type-of-networks = "projects" [ set matches projects with [project-status = "started" and count project-consortium = degree] ]
    if the-type-of-networks = "projects" [ set matches filter [? = degree] project-sizes ]
    ;if any? matches
    if length matches > 0
      [ let x log degree 10
        ;let y log (count matches) 10
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
;;; used for updating the monitors


;observer procedure
to-report show-call-status [ the-call-nr ]
  let the-call one-of calls with [call-nr = the-call-nr]
  report [call-status] of the-call
end


;observer procedure
to-report show-call-counter [ the-proposal-status ]
  report [table:get call-counter the-proposal-status] of the-current-call
end


;;; NETWORK MEASURES
;;;
;;; density, number of components, etc.


;observer procedure
to update-network-measures
  count-all-edges
  find-all-components
  ;set connected? true
  ;find-path-lengths
  ;set diameter max [max remove infinity distance-from-other-participants] of participants
  ;set num-connected-pairs sum [length remove infinity (remove 0 distance-from-other-participants)] of participants
  ;if num-connected-pairs != (count participants * (count participants - 1))
  ;  [ set connected? false ]
  ;ifelse num-connected-pairs > 0
  ;  [ set average-path-length (sum [sum remove infinity distance-from-other-participants] of participants) / (num-connected-pairs) ]
  ;  [ set average-path-length infinity ]
  find-clustering-coefficient
end


; use show-which-network to choose which is the collaborations network
; (all the network measures and exported files will be different)

; participant procedure
to-report my-network
  if show-which-network = "partners" [ report my-partners ]
  if show-which-network = "previous partners" [ report my-previous-partners ]
  if show-which-network = "partners and previous partners" [ report (turtle-set my-partners my-previous-partners) ]
end


; observer procedure
to count-all-edges
  set count-of-edges 0
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
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
  set count-of-possible-edges count participants * (count participants - 1) / 2
end


; to find all the connected components in the network, their sizes and starting nodes

; observer procedure
to find-all-components
  set number-of-components 0
  set largest-component-size 0
  ask participants [ set explored? false ]
  loop
  [
    let start one-of participants with [ not explored? ]
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
  ask participants [
    ask my-network
      [ create-link-with myself]
  ]
  ifelse all? participants [count my-network <= 1]
    [ set clustering-coefficient 0 ]
    [
      let total 0
      ask participants with [count my-network <= 1]
        [ set node-clustering-coefficient 0 ]
      ask participants with [count my-network > 1]
        [
          let hood link-neighbors
          set node-clustering-coefficient (2 * count links with [in-neighborhood? hood] / (count hood * (count hood - 1)))
          set total total + node-clustering-coefficient
        ]
      ;set clustering-coefficient total / count participants with [count link-neighbors > 1]
      set clustering-coefficient total / count participants
    ]
    clear-links
end


to find-path-lengths
  ask participants [ set distance-from-other-participants [] ]
  let i 0
  let j 0
  let k 0
  let node1 one-of participants
  let node2 one-of participants
  let node-count count participants
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


;;; EXPORT
;;;
;;; export network data to specific formats


; export network data (adjacency matrix)

;observer procedure
to export-network-data
  let file-name (word "netdata_netlogo/txt/" ticks ".txt")
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
  ; edges
  foreach participants-list [
    ask ? [
      foreach participants-list [
        ifelse member? ? my-network
          [ file-type (word "    " 1) ]
          [ file-type (word "    " 0) ]
      ]
      file-print ""
    ]
  ]
  file-close
end


; export network data in gml format

;observer procedure
to export-network-data-gml
  let file-name (word "netdata_netlogo/gml/" ticks ".gml")
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants with [count my-network > 0]
  file-print "graph ["
  ; nodes
  foreach participants-list [
    file-print "  node ["
    file-print (word "    id \"" [my-nr] of ? "\"")
    file-print (word "    type \"" [my-type] of ? "\"")
    file-print (word "    name \"" [my-name] of ? "\"")
    file-print "  ]"
  ]
  ; edges
  foreach participants-list [
    let mynr [my-nr] of ?
    ask ? [
      foreach filter [[my-nr] of ? > mynr] participants-list [
        if member? ? my-network [
          file-print "  edge ["
          file-print (word "    source \"" my-nr "\"")
          file-print (word "    target \"" [my-nr] of ? "\"")
          file-print "  ]"
        ]
      ]
    ]
  ]
  file-print "]"
  file-close
end


; export network data in gexf format

;observer procedure
to export-network-data-gexf
  let file-name (word "netdata_netlogo/gexf/" ticks ".gexf")
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  let model-version "SKIN.INFSO"
  let model-description "version 1.0"
  file-print "<?xml version=\"1.0\" encoding=\"UTF?8\"?>"
  file-print "<gexf xmlns=\"http://www.gexf.net/1.2draft\""
  file-print "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema?instance\""
  file-print "      xsi:schemaLocation=\"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd\""
  file-print "      version=\"1.2\">"
  file-print (word "  <meta lastmodifieddate=\"" date-and-time "\">")
  file-print (word "    <creator>" model-version "</creator>")
  file-print (word "    <description>" model-description "</description>")
  file-print "  </meta>"
  let participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
  file-print "  <graph defaultedgetype=\"undirected\">"
  file-print "    <attributes class=\"node\" mode=\"static\">"
  file-print "      <attribute id=\"0\" title=\"type\" type=\"string\"/>"
  file-print "      <attribute id=\"1\" title=\"name\" type=\"string\"/>"
  file-print "    </attributes>"
  ; nodes
  file-print "    <nodes>"
  set participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
  foreach participants-list [
    file-print (word "      <node id=\"" [my-nr] of ? "\" label=\"" [my-nr] of ? "\">")
    file-print "        <attvalues>"
    file-print (word "          <attvalue for=\"0\" value=\"" [my-type] of ? "\"/>")
    file-print (word "          <attvalue for=\"1\" value=\"" [my-name] of ? "\"/>")
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
        if member? ? my-network [
          file-print (word "      <edge id=\"" nr "\" source=\"" mynr "\" target=\"" [my-nr] of ? "\"/>")
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


; export network data in dynamic gexf format

;observer procedure
to export-network-data-dynamic-gexf
  let participants-list []
  ifelse ticks = 1 [
    ; adjacency matrix
    set adj-matrix array:from-list n-values (count participants * count participants) [0]
    ; create 1 file only
    let file-name "netdata_netlogo/gexf/dynamic/dynamic.gexf"
    if file-exists? file-name [ file-delete file-name ]
    file-open file-name
    let model-version "SKIN.INFSO"
    let model-description "version 1.0"
    file-print "<?xml version=\"1.0\" encoding=\"UTF?8\"?>"
    file-print "<gexf xmlns=\"http://www.gexf.net/1.2draft\""
    file-print "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema?instance\""
    file-print "      xsi:schemaLocation=\"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd\""
    file-print "      version=\"1.2\">"
    file-print (word "  <meta lastmodifieddate=\"" date-and-time "\">")
    file-print (word "    <creator>" model-version "</creator>")
    file-print (word "    <description>" model-description "</description>")
    file-print "  </meta>"
    file-print "  <graph mode=\"dynamic\" defaultedgetype=\"undirected\""
    file-print (word "         timeformat=\"integer\" start=\"" 0 "\" end=\"" nMonths "\">")
    file-print "    <attributes class=\"node\" mode=\"static\">"
    file-print "      <attribute id=\"0\" title=\"type\" type=\"string\"/>"
    file-print "    </attributes>"
    ; nodes
    file-print "    <nodes>"
    set participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
    foreach participants-list [
      file-print (word "      <node id=\"" [my-nr] of ? "\" label=\"" [my-nr] of ? "\">")
      file-print "        <attvalues>"
      file-print (word "          <attvalue for=\"0\" value=\"" [my-type] of ? "\"/>")
      file-print "        </attvalues>"
      file-print "      </node>"
    ]
    file-print "    </nodes>"
    ; edges
    file-print "    <edges>"
  ]
  [
    let file-name "netdata_netlogo/gexf/dynamic/dynamic.gexf"
    file-open file-name
    set participants-list sort-by [[my-nr] of ?1 < [my-nr] of ?2] participants
  ]
  
  let nr 1
  let ticks-nr ""
  foreach participants-list [
    let mynr [my-nr] of ?
    ask ? [
      foreach filter [[my-nr] of ? > mynr] participants-list [
        let index ((mynr - 1) * count participants) + [my-nr] of ? - 1
        if array:item adj-matrix index = 0 [
          if member? ? my-network [
            set ticks-nr (word ticks "." nr)
            file-print (word "      <edge id=\"" ticks-nr "\" source=\"" mynr "\" target=\"" [my-nr] of ? "\"")
            file-print (word "            start=\"" ticks "\"/>")
            array:set adj-matrix index 1
            set nr nr + 1
          ]
        ]
      ]
    ]
  ]
  
  ifelse ticks = nMonths [
    file-print "    </edges>"
    file-print "  </graph>"
    file-print "</gexf>"
    file-close
  ]
  [
    file-close
  ]
end


;; end of code
@#$#@#$#@
GRAPHICS-WINDOW
260
10
458
229
89
89
1.0503
1
10
1
1
1
0
0
0
1
-89
89
-89
89
0
0
1
ticks

BUTTON
15
25
77
58
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

BUTTON
90
25
153
58
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

SLIDER
5
120
235
153
nParticipants
nParticipants
0
5000
679
100
1
NIL
HORIZONTAL

PLOT
480
10
810
205
Proposals
Time (Months)
Count
0.0
112.0
0.0
100.0
true
false
PENS
"CP" 1.0 0 -2674135 true
"CSA" 1.0 0 -10899396 true
"NOE" 1.0 0 -13345367 true

PLOT
480
210
810
405
Projects
Time (Months)
Count
0.0
112.0
0.0
100.0
true
false
PENS
"CP" 1.0 0 -2674135 true
"CSA" 1.0 0 -10899396 true
"NOE" 1.0 0 -13345367 true

PLOT
480
410
810
605
Project Outputs
Time (Months)
Count
0.0
112.0
0.0
100.0
true
false
PENS
"Project count" 1.0 0 -16777216 true

BUTTON
60
780
175
813
Go Scenario
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
60
820
175
853
Load settings
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

INPUTBOX
5
405
237
570
Instrument-settings
Use \"filter on project type\" for\nselecting the Instrument
1
1
String

CHOOSER
50
870
187
915
scenario-file
scenario-file
"scenario1.skin" "scenario2.skin" "scenario3.skin"
0

SLIDER
5
200
235
233
SME-percent
SME-percent
0
100
21.06
0.01
1
NIL
HORIZONTAL

SLIDER
5
160
235
193
DFI-percent
DFI-percent
0
100
22.24
0.01
1
NIL
HORIZONTAL

MONITOR
255
35
460
80
Call 1
show-call-status 1
17
1
11

MONITOR
255
80
460
125
Call 2
show-call-status 2
17
1
11

MONITOR
255
125
460
170
Call 3
show-call-status 3
17
1
11

MONITOR
255
170
460
215
Call 4
show-call-status 4
17
1
11

MONITOR
255
215
460
260
Call 5
show-call-status 5
17
1
11

MONITOR
255
260
460
305
Call 6
show-call-status 6
17
1
11

MONITOR
1170
10
1375
55
Research institutes (RES)
count participants with [my-type = \"res\"]
17
1
11

MONITOR
1170
55
1375
100
Diversified firms (DFI)
count participants with [my-type = \"dfi\"]
17
1
11

MONITOR
1170
100
1375
145
SMEs
count participants with [my-type = \"sme\"]
17
1
11

BUTTON
165
25
228
58
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

MONITOR
1170
530
1375
575
Projects finalised
project-count
17
1
11

MONITOR
255
350
460
395
Current Call
[call-nr] of the-current-call
17
1
11

MONITOR
255
440
460
485
Call size
[call-size] of the-current-call\n
17
1
11

MONITOR
255
530
460
575
Call orientation
[call-orientation] of the-current-call
17
1
11

MONITOR
1170
170
1305
215
Proposals initiated
show-call-counter \"initiated\"
17
1
11

MONITOR
1170
215
1305
260
Proposals stopped
show-call-counter \"stopped\"
17
1
11

MONITOR
1170
260
1305
305
Proposals submitted
show-call-counter \"submitted\"
17
1
11

MONITOR
1170
370
1305
415
Proposals eligible
show-call-counter \"eligible\"
17
1
11

MONITOR
1170
415
1305
460
Proposals accepted
show-call-counter \"accepted\"
17
1
11

MONITOR
1170
460
1305
505
Proposals rejected
show-call-counter \"rejected\"
17
1
11

MONITOR
1170
325
1305
370
Proposals ineligible
show-call-counter \"ineligible\"
17
1
11

MONITOR
1305
215
1375
260
% stopped
round (1000 * show-call-counter \"stopped\" / show-call-counter \"initiated\") / 10
17
1
11

MONITOR
1305
370
1375
415
% eligible
round (1000 * show-call-counter \"eligible\" / show-call-counter \"submitted\") / 10
17
1
11

MONITOR
1305
325
1375
370
% ineligible
round (1000 * show-call-counter \"ineligible\" / show-call-counter \"submitted\") / 10
17
1
11

MONITOR
1305
415
1375
460
% accepted
round (1000 * show-call-counter \"accepted\" / show-call-counter \"eligible\") / 10
17
1
11

MONITOR
1305
460
1375
505
% rejected
round (1000 * show-call-counter \"rejected\" / show-call-counter \"eligible\") / 10
17
1
11

MONITOR
255
485
460
530
Call deadline
[call-deadline] of the-current-call
17
1
11

MONITOR
1305
260
1375
305
% submitted
round (1000 * show-call-counter \"submitted\" / show-call-counter \"initiated\") / 10
17
1
11

BUTTON
285
660
430
693
Export netdata (GML)
export-network-data-gml
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
5
80
235
113
nMonths
nMonths
0
112
112
1
1
NIL
HORIZONTAL

PLOT
820
10
1150
205
Participation in Proposals
Number of Proposals
Frequency
0.0
10.0
0.0
20.0
true
false
PENS
"Number of proposals" 1.0 1 -955883 true

PLOT
820
210
1150
405
Participation in Projects
Number of Projects
Frequency
0.0
10.0
0.0
20.0
true
false
PENS
"Number of projects" 1.0 1 -16777216 true

BUTTON
285
700
430
733
Export netdata (GEXF)
export-network-data-gexf
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
820
410
1150
605
Partners
Number of Previous Partners
Frequency
0.0
200.0
0.0
100.0
false
false
PENS
"Number of previous partners" 1.0 1 -16777216 true

BUTTON
285
620
430
653
Export netdata
export-network-data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SWITCH
5
360
235
393
invite-previous-partners-first?
invite-previous-partners-first?
0
1
-1000

SLIDER
5
240
235
273
big-RES-percent
big-RES-percent
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
5
280
235
313
big-DFI-percent
big-DFI-percent
0
100
0
1
1
NIL
HORIZONTAL

PLOT
705
785
925
935
Project Size (Regression)
Log(k)
Log(deg. distrib.)
0.0
2.0
0.0
1.0
false
false
PENS
"default" 1.0 0 -16777216 true

PLOT
705
630
925
780
Proposal Size (Regression)
Log(k)
Log(deg. distrib.)
0.0
2.0
0.0
2.0
false
false
PENS
"default" 1.0 0 -16777216 true

PLOT
480
630
700
780
Proposal Size (Distribution)
Size
Frequency
0.0
40.0
0.0
100.0
true
false
PENS
"Size of proposals" 1.0 1 -16777216 true

PLOT
480
785
700
935
Project Size (Distribution)
Size
Frequency
0.0
55.0
0.0
15.0
true
false
PENS
"Size of projects" 5.0 1 -16777216 true

PLOT
930
785
1150
935
Capability Match
Match
Frequency
0.0
10.0
0.0
100.0
true
false
PENS
"Capability match" 1.0 1 -16777216 true

PLOT
930
630
1150
780
Average Expertise Level
Expertise
Frequency
0.0
10.0
0.0
100.0
true
false
PENS
"Mean level of expertise" 1.0 1 -16777216 true

MONITOR
1300
665
1375
710
Density
round (1000 * count-of-edges / count-of-possible-edges) / 1000
17
1
11

PLOT
1395
10
1615
160
Network Density
Time (Months)
NIL
0.0
112.0
0.0
0.01
true
false
PENS
"Network density" 1.0 0 -13345367 true

MONITOR
1170
710
1375
755
Number of components
number-of-components
17
1
11

PLOT
1395
165
1615
315
Number of Components
Time (Months)
NIL
0.0
112.0
0.0
100.0
true
false
PENS
"Number of components" 1.0 0 -13345367 true

PLOT
1395
320
1615
470
Size of Largest Component
Time (Months)
NIL
0.0
112.0
0.0
100.0
true
false
PENS
"Size of largest component" 1.0 0 -13345367 true

MONITOR
1170
755
1375
800
Size of largest component
largest-component-size
17
1
11

MONITOR
1170
800
1375
845
Average degree
round (2000 * count-of-edges / count participants) / 1000
17
1
11

PLOT
1395
475
1615
625
Average Degree
Time (Months)
NIL
0.0
112.0
0.0
50.0
true
false
PENS
"Average degree" 1.0 0 -13345367 true

MONITOR
1270
845
1375
890
Average distance
round (1000 * average-path-length) / 1000
17
1
11

MONITOR
1170
890
1375
935
Clustering
round (1000 * clustering-coefficient) / 1000
17
1
11

PLOT
1395
630
1615
780
Average Distance
Time (Months)
NIL
0.0
112.0
0.0
5.0
false
false
PENS
"Average path length" 1.0 0 -13345367 true

PLOT
1395
785
1615
935
Clustering
Time (Months)
NIL
0.0
112.0
0.0
1.0
true
false
PENS
"Clustering coefficient" 1.0 0 -13345367 true

MONITOR
1170
845
1270
890
Diameter
diameter
17
1
11

SWITCH
5
580
235
613
show-empirical-case?
show-empirical-case?
0
1
-1000

CHOOSER
5
680
235
725
show-which-network
show-which-network
"partners" "previous partners"
1

MONITOR
255
395
325
440
% CP
item 0 [call-type] of the-current-call
17
1
11

MONITOR
390
395
460
440
% CSA
item 2 [call-type] of the-current-call
17
1
11

MONITOR
325
395
390
440
% NOE
item 1 [call-type] of the-current-call
17
1
11

CHOOSER
5
620
235
665
filter-on-project-type
filter-on-project-type
"CP" "CSA" "NOE"
1

MONITOR
1235
665
1300
710
Edges
count-of-edges
17
1
11

MONITOR
1170
665
1235
710
Nodes
count participants
17
1
11

SLIDER
5
320
235
353
capability-match-threshold
capability-match-threshold
0
20
15
1
1
NIL
HORIZONTAL

MONITOR
1170
575
1375
620
Avg. project size
round (10 * sum-of-project-sizes / project-count) / 10
17
1
11

@#$#@#$#@
WHAT IS IT?
-----------
SKIN (Simulating Knowledge Dynamics in Innovation Networks) is a multi-agent model of innovation networks in knowledge-intensive industries grounded in empirical research and theoretical frameworks from innovation economics and economic sociology. The agents represent innovative firms who try to sell their innovations to other agents and end users but who also have to buy raw materials or more sophisticated inputs from other agents (or material suppliers) in order to produce their outputs. This basic model of a market is extended with a representation of the knowledge dynamics in and between the firms. Each firm tries to improve its innovation performance and its sales by improving its knowledge base through adaptation to user needs, incremental or radical learning, and co-operation and networking with other agents.


HOW IT WORKS
------------

The agents

The individual knowledge base of a SKIN agent, its kene, contains a number of “units of knowledge”. Each unit in a kene is represented as a triple consisting of a firm’s capability C in a scientific, technological or business domain, its ability A to perform a certain application in this field, and the expertise level E the firm has achieved with respect to this ability. The units of knowledge in the kenes of the agents can be used to describe their virtual knowledge bases. 

The market

Because actors in empirical innovation networks of knowledge-intensive industries interact on both the knowledge and the market levels, there needs to be a representation of market dynamics in the SKIN model. Agents are therefore characterised by their capital stock. Each firm, when it is set up, has a stock of initial capital. It needs this capital to produce for the market and to finance its R&D expenditures; it can increase its capital by selling products. The amount of capital owned by a firm is used as a measure of its size and additionally influences the amount of knowledge (measured by the number of triples in its kene) that it can maintain.  Most firms are initially given the same starting capital allocation, but in order to model differences in firm size, a few randomly chosen firms can be allocated extra capital. 

Firms apply their knowledge to create innovative products that have a chance of being successful in the market. The special focus of a firm, its potential innovation, is called an innovation hypothesis. In the model, the innovation hypothesis (IH) is derived from a subset of the firm’s kene triples.
 
The underlying idea for an innovation, modelled by the innovation hypothesis, is the source an agent uses for its attempts to make profits in the market. Because of the fundamental uncertainty of innovation, there is no simple relationship between the innovation hypothesis and product development. To represent this uncertainty,  the innovation hypothesis is transformed into a product through a mapping procedure where the capabilities of the innovation hypothesis are used to compute an index number that represents the product. The particular transformation procedure applied allows the same product to result from different kenes.

A firm’s product, P, is generated from its innovation hypothesis as
                                             
P = Sum (capability * ability) mod N

where N is a large constant and represents the notional total number of possible different products that could be present in the market).

A product has a certain quality, which is also computed from the innovation hypothesis in a similar way, by multiplying the abilities and the expertise levels for each triple in the innovation hypothesis and normalising the result. Whereas the abilities used to design a product can be used as a proxy for its product characteristics, the expertise of the applied abilities is an indicator of the potential product quality. 

In order to realise the product, the agent needs some materials. These can either come from outside the sector (“raw materials”) or from other firms, which generated them as their products. Which materials are needed is again determined by the underlying innovation hypothesis: the kind of material required for an input is obtained by selecting subsets from the innovation hypotheses and applying the standard mapping function. 

These inputs are chosen so that each is different and differs from the firm’s own product. In order to be able to engage in production, all the inputs need to be obtainable on the market, i.e. provided by other firms or available as raw materials. If the inputs are not available, the firm is not able to produce and has to give up this attempt to innovate. If there is more than one supplier for a certain input, the agent will choose the one at the cheapest price and, if there are several similar offers, the one with the highest quality. 
 
If the firm can go into production, it has to find a price for its product, taking into account the input prices it is paying and a possible profit margin. While the simulation starts with product prices set at random, as the simulation proceeds a price adjustment mechanism following a standard mark-up pricing model increases the selling price if there is much demand, and reduces it (but no lower than the total cost of production) if there are no customers.  Some products are considered to be destined for the ‘end-user’ and are sold to customers outside the sector: there is always a demand for such end-user products provided that they are offered at or below a fixed end-user price. A firm buys the requested inputs from its suppliers using its capital to do so, produces its output and puts it on the market for others to purchase. Using the price adjustment mechanism, agents are able to adapt their prices to demand and in doing so learn by feedback. 

In making a product, an agent applies the knowledge in its innovation hypothesis and this increases its expertise in this area. This is the way that learning by doing/using is modelled. The expertise levels of the triples in the innovation hypothesis are increased and the expertise levels of the other triples are decremented. Expertise in unused triples in the kene is eventually lost and the triples are then deleted from the kene; the corresponding abilities are “forgotten”.

Thus, in trying to be successful on the market, firms are dependent on their innovation hypothesis, i.e. on their kene. If a product does not meet any demand, the firm has to adapt its knowledge in order to produce something else for which there are customers. A firm has several ways of improving its performance, either alone or in co-operation, and in either an incremental or a more radical fashion. 

Learning and co-operation: improving innovation performance

In the SKIN model, firms may engage in single- and double-loop learning activities. Firm agents can:
*	use their capabilities (learning by doing/using) and learn to estimate their success via feedback from markets and clients (learning by feedback) as already mentioned above and/or
*	improve their own knowledge incrementally when the feedback is not satisfactory in order to adapt to changing technological and/or economic standards (adaptation learning, incremental learning).

If a firm’s previous innovation has been successful, i.e. it has found buyers, the firm will continue selling the same product in the next round, possibly at a different price depending on the demand it has experienced. However, if there were no sales, it considers that it is time for change. If the firm still has enough capital, it will carry out “incremental” research (R&D in the firm’s labs). Performing incremental research means that a firm tries to improve its product by altering one of the abilities chosen from the triples in its innovation hypothesis, while sticking to its focal capabilities. The ability in each triple is considered to be a point in the respective capability’s action space. To move in the action space means to go up or down by an increment, thus allowing for two possible “research directions”. 

Alternatively, firms can radically change their capabilities in order to meet completely different client requirements (innovative learning, radical learning). A SKIN firm agent under serious pressure and in danger of becoming bankrupt, will turn to more radical measures, by exploring a completely different area of market opportunities. In the model, an agent under financial pressure turns to a new innovation hypothesis after first “inventing” a new capability for its kene. This is done by randomly replacing a capability in the kene with a new one and then generating a new innovation hypothesis. 

An agent in the model may consider partnerships (alliances, joint ventures etc.) in order to exploit external knowledge sources. The decision whether and with whom to co-operate is based on the mutual observations of the firms, which estimate the chances and requirements coming from competitors, possible and past partners, and clients.  In the SKIN model, a marketing feature provides the information that a firm can gather about other agents: to advertise its product, a firm publishes the capabilities used in its innovation hypothesis. Those capabilities not included in its innovation hypothesis and thus in its product are not visible externally and cannot be used to select the firm as a partner. The firm’s ‘advertisement’ is then the basis for decisions by other firms to form or reject co-operative arrangements.

In experimenting with the model, one can choose between two different partner search strategies, both of which compare the firm’s own capabilities as used in its innovation hypothesis and the possible partner’s capabilities as seen in its advertisement. Applying the conservative strategy, a firm will be attracted to a partner that has similar capabilities; using a progressive strategy the attraction is based on the difference between the capability sets. 

To find a partner, the firm will look at previous partners first, then at its suppliers, customers and finally at all others. If there is a firm sufficiently attractive according to the chosen search strategy (i.e. with attractiveness above the ‘attractiveness threshold’), it will stop its search and offer a partnership. If the potential partner wishes to return the partnership offer, the partnership is set up. 

The model assumes that partners learn only about the knowledge being actively used by the other agent. Thus, to learn from a partner, a firm will add the triples of the partner’s innovation hypothesis to its own. For capabilities that are new to it, the expertise levels of the triples taken from the partner are reduced in order to mirror the difficulty of integrating external knowledge as stated in empirical learning research.  For partner’s capabilities that are already known to it, if the partner has a higher expertise level, the firm will drop its own triple in favour of the partner’s one; if the expertise level of a similar triple is lower, the firm will stick to its own version. Once the knowledge transfer has been completed, each firm continues to produce its own product, possibly with greater expertise as a result of acquiring skills from its partner.

If the firm’s last innovation was successful, i.e. the value of its profit in the previous round was above a threshold, and the firm has some partners at hand, it can initiate the formation of a network. This can increase its profits because the network will try to create innovations as an autonomous agent in addition to those created by its members and will distribute any rewards back to its members who, in the meantime, can continue with their own attempts, thus providing a double chance for profits. Networks are “normal” agents, i.e. they get the same amount of initial capital as other firms and can engage in all the activities available to other firms. The kene of a network is the union of the triples from the innovation hypotheses of all its participants. If a network is successful it will distribute any earnings above the amount of the initial capital to its members; if it fails and becomes bankrupt, it will be dissolved. 

Start-ups

If a sector is successful, new firms will be attracted into it. This is modelled by adding a new firm to the population when any existing firm makes a substantial profit. The new firm is a clone of the successful firm, but with its kene triples restricted to those in the successful firm’s advertisement and these having a low expertise level. This models a new firm copying the characteristics of those seen to be successful in the market. As with all firms, the kene may also be restricted because the initial capital of a start-up is limited and may not be sufficient to support the copying of the whole of the successful firm’s innovation hypothesis.





REFERENCES
----------
More information about SKIN and research based on it can be found at: http://cress.soc.surrey.ac.uk/skin/home


The following papers describe the model and how it has been used by its originators:

Gilbert, Nigel, Pyka, Andreas, & Ahrweiler, Petra. (2001b). Innovation networks - a simulation approach. Journal of Artificial Societies and Social Simulation, 4(3)8, <http://www.soc.surrey.ac.uk/JASSS/4/3/8.html>.

Vaux, Janet, & Gilbert, Nigel. (2003). Innovation networks by design: The case of the mobile VCE. In A. Pyka & G. Küppers (Eds.), Innovation networks: Theory and practice. Cheltenham: Edward Elgar.

Pyka, Andreas, Gilbert, Nigel, & Ahrweiler, Petra. (2003). Simulating innovation networks. In A. Pyka & G. Küppers; (Eds.), Innovation networks: Theory and practice. Cheltenham: Edward Elgar.

Ahrweiler, Petra, Pyka, Andreas, & Gilbert, Nigel. (2004). Simulating knowledge dynamics in innovation networks (SKIN). In R. Leombruni & M. Richiardi (Eds.),Industry and labor dynamics: The agent-based computational economics approach. Singapore: World Scientific Press.

Ahrweiler, Petra, Pyka, Andreas & Gilbert, Nigel. (2004), Die Simulation von Lernen in Innovationsnetzwerken, in: Michael Florian und Frank Hillebrandt (eds.): Adaption und Lernen in und von Organisationen. VS-Verlag für Sozialwissenschaften, Opladen 2004, 165-186.

Pyka, A. (2006), Modelling Qualitative Development. Agent Based Approaches in Economics, in: Rennard, J.-P. (Hrsg.), Handbook of Research on Nature Inspired Computing for Economy and Management, Idea Group Inc., Hershey, USA, 211-224.

Gilbert, Nigel, Ahrweiler, Petra, & Pyka, Andreas. (2007). Learning in innovation networks: Some simulation experiments. Physica A, 378, 100-109.

Pyka, Andreas, Gilbert, Nigel, & Ahrweiler, Petra. (2007). Simulating knowledge-generation and distribution processes in innovation collaborations and networks. Cybernetics and Systems, 38 (7), 667-693.

Pyka, Andreas, Gilbert, Nigel & Petra Ahrweiler (2009), Agent-Based Modelling of Innovation Networks – The Fairytale of Spillover, in: Pyka, A. and Scharnhorst, A. (eds.), Innovation Networks – New Approaches in Modelling and Analyzing, Springer: Complexity, Heidelberg and New York, 101-126.

Gilbert, N., P. Ahrweiler and A. Pyka (2010): Learning in Innovation Networks: some Simulation Experiments. In P. Ahrweiler, (ed.) : Innovation in complex social systems. London: Routledge (Reprint from Physica A, 2007), pp. 235-249.

Scholz, R., T. Nokkala, P. Ahrweiler, A. Pyka and N. Gilbert (2010): The agent-based Nemo Model (SKEIN) – simulating European Framework Programmes. In P. Ahrweiler (ed.): Innovation in complex social systems. London: Routledge, pp. 300-314.

Ahrweiler, P., A. Pyka and N. Gilbert (forthcoming): A new Model for University-Industry Links in knowledge-based Economies. Journal of Product Innovation Management.

Ahrweiler, P., N. Gilbert and A. Pyka (2010): Agency and Structure. A social simulation of knowledge-intensive Industries. Computational and Mathematical Organization Theory (forthcoming).


CREDITS
-------


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
NetLogo 4.1.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Bourdieu experiment 2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>date-and-time</metric>
    <metric>step</metric>
    <metric>total-innovations</metric>
    <metric>gamma</metric>
    <metric>count firms</metric>
    <metric>sum [ in-partnership ] of firms</metric>
    <metric>count firms with [is-agent? network ]</metric>
    <metric>count networks</metric>
    <metric>herfindahl</metric>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;no partners&quot;"/>
      <value value="&quot;conservative&quot;"/>
      <value value="&quot;progressive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Bourdieu experiment 4 (Attractiveness)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>date-and-time</metric>
    <metric>step</metric>
    <metric>total-innovations</metric>
    <metric>gamma</metric>
    <metric>count firms</metric>
    <metric>sum [ in-partnership ] of firms</metric>
    <metric>count firms with [is-agent? network ]</metric>
    <metric>count networks</metric>
    <metric>herfindahl</metric>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-capacity">
      <value value="&quot;Off&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="OL experiment" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>date-and-time</metric>
    <metric>learning-level</metric>
    <metric>total-age-of-the-firms</metric>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-capacity">
      <value value="&quot;Off&quot;"/>
      <value value="&quot;None&quot;"/>
      <value value="&quot;Learning by doing&quot;"/>
      <value value="&quot;Price adjust&quot;"/>
      <value value="&quot;Incr research&quot;"/>
      <value value="&quot;Radical research&quot;"/>
      <value value="&quot;Partnering&quot;"/>
      <value value="&quot;Networking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="OL experiment for successful innovations" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>date-and-time</metric>
    <metric>learning-level</metric>
    <metric>total-age-of-the-firms</metric>
    <metric>successes-of-the-firms</metric>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-capacity">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Learning by doing&quot;"/>
      <value value="&quot;Price adjust&quot;"/>
      <value value="&quot;Incr research&quot;"/>
      <value value="&quot;Radical research&quot;"/>
      <value value="&quot;Partnering&quot;"/>
      <value value="&quot;Networking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Growth of Market 2 experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2500"/>
    <exitCondition>count firms &gt; 2000</exitCondition>
    <metric>count firms</metric>
    <metric>sum [capital] of firms</metric>
    <metric>sum [in-partnership] of firms</metric>
    <metric>count firms with [is-agent? network]</metric>
    <metric>count networks</metric>
    <metric>count firms with [last-reward &gt; success-threshold]</metric>
    <metric>count firms with [age = 0 and not network-firm ]</metric>
    <metric>count firms with [selling? = true]</metric>
    <metric>sum [nCustomers] of firms</metric>
    <metric>count firms with [done-rad-research]</metric>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="learning-capacity">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Price adjust&quot;"/>
      <value value="&quot;Incr research&quot;"/>
      <value value="&quot;Radical research&quot;"/>
      <value value="&quot;Partnering&quot;"/>
      <value value="&quot;Networking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="view">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Growth-of-market-3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>count firms &gt; 2000</exitCondition>
    <metric>Adj-expertise</metric>
    <metric>Adj-price</metric>
    <metric>Incr-research</metric>
    <metric>Rad-research</metric>
    <metric>Partnering</metric>
    <metric>Networking</metric>
    <metric>count firms</metric>
    <metric>sum [capital] of firms</metric>
    <metric>sum [in-partnership] of firms</metric>
    <metric>count firms with [is-agent? network]</metric>
    <metric>count networks</metric>
    <metric>count firms with [last-reward &gt; success-threshold]</metric>
    <metric>count firms with [age &lt;= 1 and not network-firm ]</metric>
    <metric>count firms with [selling? = true]</metric>
    <metric>sum [nCustomers] of firms</metric>
    <metric>count firms with [done-rad-research]</metric>
    <metric>median-dead-ages</metric>
    <metric>date-and-time</metric>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="view">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clock">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="exp-condition" first="1" step="1" last="7"/>
  </experiment>
  <experiment name="No-Growth-of-market-incr+rad" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1500"/>
    <metric>Adj-expertise</metric>
    <metric>Adj-price</metric>
    <metric>Incr-research</metric>
    <metric>Rad-research</metric>
    <metric>Partnering</metric>
    <metric>Networking</metric>
    <metric>count firms</metric>
    <metric>sum [capital] of firms</metric>
    <metric>sum [in-partnership] of firms</metric>
    <metric>count firms with [is-agent? network]</metric>
    <metric>count networks</metric>
    <metric>count firms with [last-reward &gt; success-threshold]</metric>
    <metric>count firms with [age &lt;= 1 and not network-firm ]</metric>
    <metric>count firms with [selling? = true]</metric>
    <metric>sum [nCustomers] of firms</metric>
    <metric>count firms with [done-rad-research]</metric>
    <metric>median-dead-ages</metric>
    <metric>date-and-time</metric>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="view">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clock">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exp-condition">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Growth-of-market-incr+rad" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1500"/>
    <metric>Adj-expertise</metric>
    <metric>Adj-price</metric>
    <metric>Incr-research</metric>
    <metric>Rad-research</metric>
    <metric>Partnering</metric>
    <metric>Networking</metric>
    <metric>count firms</metric>
    <metric>sum [capital] of firms</metric>
    <metric>sum [in-partnership] of firms</metric>
    <metric>count firms with [is-agent? network]</metric>
    <metric>count networks</metric>
    <metric>count firms with [last-reward &gt; success-threshold]</metric>
    <metric>count firms with [age &lt;= 1 and not network-firm ]</metric>
    <metric>count firms with [selling? = true]</metric>
    <metric>sum [nCustomers] of firms</metric>
    <metric>count firms with [done-rad-research]</metric>
    <metric>median-dead-ages</metric>
    <metric>date-and-time</metric>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="view">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clock">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Start-ups">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exp-condition">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="No-growth-of-market-all" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>count firms &gt; 2000</exitCondition>
    <metric>Adj-expertise</metric>
    <metric>Adj-price</metric>
    <metric>Incr-research</metric>
    <metric>Rad-research</metric>
    <metric>Partnering</metric>
    <metric>Networking</metric>
    <metric>count firms</metric>
    <metric>sum [capital] of firms</metric>
    <metric>sum [in-partnership] of firms</metric>
    <metric>count firms with [is-agent? network]</metric>
    <metric>count networks</metric>
    <metric>count firms with [last-reward &gt; success-threshold]</metric>
    <metric>count firms with [age &lt;= 1 and not network-firm ]</metric>
    <metric>count firms with [selling? = true]</metric>
    <metric>sum [nCustomers] of firms</metric>
    <metric>count firms with [done-rad-research]</metric>
    <metric>median-dead-ages</metric>
    <metric>date-and-time</metric>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="view">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="650"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clock">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="exp-condition" first="1" step="1" last="7"/>
    <enumeratedValueSet variable="Start-ups">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="OL experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <exitCondition>count firms &gt; 2000</exitCondition>
    <metric>count firms</metric>
    <metric>sum [capital] of firms</metric>
    <metric>sum [in-partnership] of firms</metric>
    <metric>count firms with [is-agent? network]</metric>
    <metric>count networks</metric>
    <metric>count firms with [last-reward &gt; success-threshold]</metric>
    <metric>count firms with [age &lt;= 1 and not network-firm ]</metric>
    <metric>count firms with [selling? = true]</metric>
    <metric>sum [nCustomers] of firms</metric>
    <metric>count firms with [done-rad-research]</metric>
    <metric>median-dead-ages</metric>
    <metric>date-and-time</metric>
    <enumeratedValueSet variable="Start-ups">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nProducts">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nInputs">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="open-system">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showNetworks">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showPartners">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Adj-price">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="In-sector-capabilities">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nFirms">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="partnership-strategy">
      <value value="&quot;conservative&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attractiveness-threshold">
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="exp-condition" first="1" step="1" last="7"/>
    <enumeratedValueSet variable="Networking">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="showSales">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="view">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clock">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Rad-research">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-big-firms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Adj-expertise">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Partnering">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Incr-research">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="delta">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incr-step">
      <value value="1.783"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reward-to-trigger-start-up">
      <value value="1250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="success-threshold">
      <value value="800"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
