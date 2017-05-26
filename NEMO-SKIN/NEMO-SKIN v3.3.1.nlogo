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
;Copyright 2003 - 2017 Nigel Gilbert, Petra Ahrweiler and Andreas Pyka. All rights reserved.
;
;Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed: a) this copyright notice is included. b) this model will not be redistributed for profit without permission and c) the requirements of the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License <http://creativecommons.org/licenses/by-nc-sa/3.0/> are complied with.
;
;The authors gratefully acknowledge funding during the course of development of the model from the European Commission, DAAD, and the British Council.
;
;
;This modification to SKIN, for the NEMO project, copyright Andreas Pyka under the above licence terms, 2007
;
; Requires NetLogo version 4.0.5 from https://ccl.northwestern.edu/netlogo/download.shtml
;
;Results from this model publiched in:
;
;Sholz, R., Nokkala, T., Ahrweiler, P., Pyka, A., & Gilbert, G. N. (2010). The agent-based NEMO model (SKEIN): simulating European Framework Programmes. In P. Ahrweiler (Ed.), Innovation in Complex Social Systems (pp. 300-314). London: Routledge, Taylor & Francis Group.
;

; Including not in NetLogo implemented commands
extensions [ FileManagement ]
; Command:           Input:                     reports:                            funktion: 
;
; mkDir              absolute path              "new", "exists" or "error"          creates a new directory ; returns 




; globals preceded by ';' below are set by sliders, not by code
globals [
    period                                     ; time step
    stop-now                                   ; if true, the simulation stops immediately
    initial-capital                            ; the capital that a firm starts with
    initial-capital-variance                   ; the capital variance of the firms at the begining ( +- this value)
    tax                                        ; Standard tax every agent has to pay every period
    project-revenue                            ; Standard revenue in each period a project partner gains
    global-number-count                        ; sets the internal number for the agents
    number-of-start-firms                      ;
    number-of-start-universities               ;
    number-of-start-research-institutes        ;
    kene-share-main-field-f                    ;
    kene-share-main-field-u                    ;
    kene-share-main-field-r                    ;
    number-of-research-directions              ;
    number-of-capabilities                     ;
    number-of-abilities                        ;
    number-of-start-expertise                  ;
    distance-wight-research-directions         ;
    distance-wight-capabilities                ;
    distance-wight-abilities                   ;
    current-activity                           ; shows the step the program is running in the screen
    kene-counter                               ;
    maximum-candidates                         ;
    search-forup-to-?-random-candidates        ;
    number-of-partners-min
    number-of-partners-max
    number-of-partners-max-rnd
    number-of-partners-min-big
    number-of-partners-max-big
    number-of-partners-max-big-rnd  
    number-of-partners-min-use  
    number-of-partners-max-use
    percentage-of-prefered-partners            ;
    minimum-cooperation-value                  ; the minimum likekiness value for a cooperation
    maximum-value-short-distance-cons          ; The maximum value of the short distance for a cooperation with the strategy conservative
    maximum-value-long-distance-cons           ; The maximum value of the long distance for a cooperation with the strategy conservative
    minimum-value-short-distance-prog          ; The minimum value of the short distance for a cooperation with the strategy progessive
    minimum-value-long-distance-prog           ; The minimum value of the short distance for a cooperation with the strategy progessive
    
    border-short-distance-cons                 ; The border value of the short distance for a cooperation with the strategy conservative
    percentage-short-distance-cons             ; The min. percentage of kene-pairs, which have to have to be under the value border-short-distance-cons
    border-long-distance-cons                  ; The border value of the long distance for a cooperation with the strategy conservative
    percentage-long-distance-cons              ; The max percentage of kene-pairs, which can be above the value border-long-distance-cons
    border-short-distance-prog                 ; The border value of the short distance for a cooperation with the strategy progessive
    percentage-short-distance-prog             ; The max percentage of kene-pairs, which can be under the value border-short-distance-prog
    border-long-distance-prog                  ; The border value of the short distance for a cooperation with the strategy progessive
    percentage-long-distance-prog              ; The min percentage of kene-pairs, which have to have to be above the value border-long-distance-prog
    
    
    number-of-kene-triples-from-research-project
    number-of-kene-triples-from-kene
    number-of-accepted-proposals-con
    number-of-accepted-proposals-rad
    this-project
    positive-proposal-increment
    negative-proposal-increment
    time-increment-network-value               ; Represents the value of the change of the network-value in % over time (e.g 0.05 --> 5% gain or loos of the vlaue each period)
    Number-of-current-projects
    
    current-proposals-formulated
    current-output-of-all-projects
    current-Connectivity-of-all-institutes
    current-number-of-institutes
    Duration-of-projects-minimum-value
    Random-term-duration-Projects
    minimum-value-for-edges-internal
    ;current-run-number
    Value-For-Networks
    institute-list
    project-list
    absolute-save-path
    pajek-adjacency-matrix-separator
    pajek-adjacency-matrix-file-ending
    
    ;scenario-file
    max-current-proposals-global
    max-all-projects-global
    number-of-big-agents-firms
    number-of-big-agents-research-institutes
    number-of-members-big-agent
    ;number-of-different-locations
    Number-of-Export-Variables
    Data-file
    
    
    
    
    debug-1
    debug-2
    debug-3
  ]
;  
;
; 
breed [ institutes institute ]
breed [ edges edge ]
breed [ proposal-groups proposal-group ]
breed [ projects project ]
breed [ Big-agents big-agent ]
;
;
;
institutes-own [
  kind
  age
  kene
  research-project
  capital
  network
  possible-partners
  partners
  current-search-strategy                                         ; possible values: "conservative" and "progressive"
  number-of-current-proposals
  number-of-all-projects
  max-current-proposals
  max-all-projects
  all-proposals
  proposal-partners
  all-projects
  project-partners
  Positive-network-bindings
  big-agent-component?
  big-agent-ID
  location
  ]
;
;
;
Big-agents-own [
  members
  capital
  kind
  Positive-network-bindings
  ]

edges-own [
  a 
  b
  kind
  ]
;
;
;
proposal-groups-own [
  kene
  members
  number-of-proposal-capabilities
  research-strategy-of-proposal
  ]
; 
;
;
projects-own [
  age
  project-duration
  kene
  members
  current-work
  previous-work
  research-strategy-of-project
  total-successful-work-value
  ]
;
;
;
to setup-normal
  ca 
  file-close-all
    
  set absolute-save-path user-directory
  setup

end
;
;
;
to setup-montecarlo
  ct
  cd
  cp
  clear-all-plots
  ;ca
  setup
end
;
;
;
to setup
    set current-activity "Initialising" 
    no-display
    setup-variables
    setup-lists
    setup-layout
    create-agents
    create-the-big-agents
    
    
    
    display
    set current-activity "Initialised" 
end
;
;
; 
to setup-scenario-file
    ca 
    file-close-all
    set current-activity "Initialising" 
    no-display
    setup-variables
    setup-lists
    setup-layout
    let current-variables read-Skein-File-line 1
    set-skein-file-variables current-variables
    create-agents
    create-the-big-agents
    
    
    
    
    display
    set current-activity "Initialised" 
end
;
;
; 
to setup-variables
  set period                                                              1        ;
  set stop-now                                                        false        ;
  set initial-capital                                                  2000        ;
  set initial-capital-variance                        initial-capital * 0.1        ;
  set tax                                                               100        ;
  set project-revenue                                             tax * 1.2        ;
  set global-number-count                                                 0        ;
  set number-of-start-firms                                             600        ;
  set number-of-start-universities                                      300        ;
  set number-of-start-research-institutes                               300        ;
  set kene-share-main-field-f                                           0.6        ;
  set kene-share-main-field-u                                           0.6        ;
  set kene-share-main-field-r                                           0.6        ;
  set number-of-research-directions                                      10        ; starting with 0 till this value - 1
  set number-of-capabilities                                            100        ;
  set number-of-abilities                                                10        ;
  set number-of-start-expertise                                          20        ;
  set distance-wight-research-directions  1 / number-of-research-directions        ;
  set distance-wight-capabilities                                         1        ;
  set distance-wight-abilities                                            1        ;
  set maximum-candidates                                                 10        ;
  set search-forup-to-?-random-candidates                                50        ;
  set number-of-partners-min                                   random 3 + 2
  ;set number-of-partners-max              number-of-partners-min + random 3  
  set number-of-partners-max-rnd                                          3   
  set number-of-partners-min-big                               random 3 + 5
  ;set number-of-partners-max-big      number-of-partners-min-big + random 8 
  set number-of-partners-max-big                                          8  
  ;set with-big-projects                                                true          
  set percentage-of-prefered-partners              maximum-candidates * 0.8        ;
  set minimum-cooperation-value                                         0.5        ;
  set maximum-value-short-distance-cons                                  20        ; The maximum value of the short distance for a cooperation with the strategy conservative
  set maximum-value-long-distance-cons                                   60        ; The maximum value of the long distance for a cooperation with the strategy conservative
  set minimum-value-short-distance-prog                                  10        ; The minimum value of the short distance for a cooperation with the strategy progessive
  set minimum-value-long-distance-prog                                   40        ; The minimum value of the short distance for a cooperation with the strategy progessive  
  
  set border-short-distance-cons                                         20        ; The border value of the short distance for a cooperation with the strategy conservative
  set percentage-short-distance-cons                                    0.4        ; The min. percentage of kene-pairs, which have to have to be under the value border-short-distance-cons
  set border-long-distance-cons                                          70        ; The border value of the long distance for a cooperation with the strategy conservative
  set percentage-long-distance-cons                                     0.2        ; The max percentage of kene-pairs, which can be above the value border-long-distance-cons
  set border-short-distance-prog                                         20        ; The border value of the short distance for a cooperation with the strategy progessive
  set percentage-short-distance-prog                                    0.2        ; The max percentage of kene-pairs, which can be under the value border-short-distance-prog
  set border-long-distance-prog                                          70        ; The border value of the short distance for a cooperation with the strategy progessive
  set percentage-long-distance-prog                                     0.4        ; The min percentage of kene-pairs, which have to have to be above the value border-long-distance-prog
    
  
  
  set number-of-kene-triples-from-research-project                        2        ;
  set number-of-kene-triples-from-kene                                    1        ;
  ;set number-of-accepted-proposals-con                                    4        ;
  ;set number-of-accepted-proposals-rad                                    4        ;     
  set positive-proposal-increment                                       0.1
  set negative-proposal-increment                                     -0.05
  set time-increment-network-value                                     0.05        ; Represents the value of the change of the network-value in % over time (e.g 0.05 --> 5% gain or loos of the vlaue each period)
  set current-proposals-formulated                                        0
  set institute-list                                                     []
  ;set current-run-number                                                  1
  set Value-For-Networks                                                  1
  set pajek-adjacency-matrix-separator                                  " "
  set pajek-adjacency-matrix-file-ending                              ".net"
  
  set max-current-proposals-global                                         2
  set max-all-projects-global                                              5
  set number-of-big-agents-firms                             round (number-of-start-firms / 20)
  set number-of-big-agents-research-institutes               round (number-of-start-research-institutes / 30 )
  set number-of-members-big-agent                                          8
  set Number-of-Export-Variables                                           5     
  set Data-file                                            "Variables.skein"
  
  

end
;
;
;
to setup-lists
  
  
  
end
;
;
;
to setup-layout
  ;set-default-shape institutes with [ kind = "firm" ]                       "factory"
  ;set-default-shape institutes with [ kind = "university" ]                 "building store"  
  ;set-default-shape institutes with [ kind = "research-institute" ]         "house ranch"  
  set-default-shape edges                                                  "line"
  
  
end
;
;
;
to create-agents
  create-institutes                 number-of-start-firms                  [initialise-firms]
  create-institutes                 number-of-start-universities           [initialise-universities]
  create-institutes                 number-of-start-research-institutes    [initialise-research-institutes]
  
  
end
;
;
;
to initialise-firms
  setxy random-xcor random-ycor
  set   kind                                     "firm"
  set   age                                      0
  set   kene                                     []
  set   research-project                         []
  set   capital                                  initial-capital + (random  ((initial-capital-variance * 2) + 1) - initial-capital-variance)
  set   network                                  []
  set   size                                     5
  set   color                                    35
  set   possible-partners                        []
  set   partners                                 []
  set   current-search-strategy                  one-of ["conservative" "progressive"]
  set   shape                                    "factory"
  set   number-of-current-proposals              0
  set   number-of-all-projects                   0
  set   max-current-proposals                    max-current-proposals-global
  set   max-all-projects                         max-all-projects-global
  set   all-proposals                            []
  set   proposal-partners                        []
  set   all-projects                             []
  set   project-partners                         []
  set   Positive-network-bindings                []
  set   big-agent-component?                     false
  set   big-agent-ID                             0
  ifelse xcor > 0 
    [ifelse ycor > 0 [set location 1][set location 4]]
    [ifelse ycor > 0 [set location 2][set location 3]]
  make-kene-firms
  make-research-project
  
  
end
;
;
;
to initialise-universities
  setxy random-xcor random-ycor
  set   kind                                     "university"
  set   age                                      0
  set   kene                                     []
  set   research-project                         []
  set   capital                                  initial-capital + (random  ((initial-capital-variance * 2) + 1) - initial-capital-variance) 
  set   network                                  []
  set   size                                     5
  set   color                                    65
  set   possible-partners                        []
  set   partners                                 []
  set   current-search-strategy                  one-of ["conservative" "progressive"]
  set   shape                                    "building store"
  set   number-of-current-proposals              0
  set   number-of-all-projects                   0
  set   max-current-proposals                    max-current-proposals-global
  set   max-all-projects                         max-all-projects-global
  set   all-proposals                            []
  set   proposal-partners                        []
  set   all-projects                             []
  set   project-partners                         []
  set   Positive-network-bindings                []
  set   big-agent-component?                     false
  set   big-agent-ID                             0
  ifelse xcor > 0 
    [ifelse ycor > 0 [set location 1][set location 4]]
    [ifelse ycor > 0 [set location 2][set location 3]]
  make-kene-universities
  make-research-project
  
  
end
;
;
;
to initialise-research-institutes
  setxy random-xcor random-ycor
  set   kind                                     "research-institute"
  set   age                                      0
  set   kene                                     []
  set   research-project                         []
  set   capital                                  initial-capital + (random  ((initial-capital-variance * 2) + 1) - initial-capital-variance)
  set   network                                  []
  set   size                                     5
  set   color                                    85
  set   possible-partners                        []
  set   partners                                 []
  set   current-search-strategy                  one-of ["conservative" "progressive"]
  set   shape                                    "house ranch"
  set   number-of-current-proposals              0
  set   number-of-all-projects                   0
  set   max-current-proposals                    max-current-proposals-global
  set   max-all-projects                         max-all-projects-global
  set   all-proposals                            []
  set   proposal-partners                        []
  set   all-projects                             []
  set   project-partners                         []
  set   Positive-network-bindings                []
  set   big-agent-component?                     false
  set   big-agent-ID                             0
  ifelse xcor > 0 
    [ifelse ycor > 0 [set location 1][set location 4]]
    [ifelse ycor > 0 [set location 2][set location 3]]
  make-kene-research-institutes
  make-research-project
  
  
end
;
;
;
to make-kene-firms
  let kene-length 10;  
  let recent-triple 0
  while  [(kene-length *  kene-share-main-field-f) > recent-triple] [
    make-kene-triple 
    ifelse item 0 item recent-triple kene  != 0 
      [set recent-triple recent-triple + 1]
      [set kene remove-item recent-triple kene]
  ]
  while [recent-triple < kene-length] [
    make-kene-triple
    set recent-triple recent-triple + 1
  ]
  
end
;
;
;
to make-kene-universities
  let kene-length 10;  
  let recent-triple 0
  while  [(kene-length *  kene-share-main-field-u) > recent-triple] [
    make-kene-triple 
    ifelse item 0 item recent-triple kene  = 0 
      [set recent-triple recent-triple + 1]
      [set kene remove-item recent-triple kene]
  ]
  while [recent-triple < kene-length] [
    make-kene-triple
    set recent-triple recent-triple + 1
  ]  
  
  
end
;
;
;
to make-kene-research-institutes
  let kene-length 10;  
  let recent-triple 0
  while  [(kene-length *  kene-share-main-field-r) > recent-triple] [
    make-kene-triple 
    ifelse item 0 item recent-triple kene  = 0 
      [set recent-triple recent-triple + 1]
      [set kene remove-item recent-triple kene]
  ]
  while [recent-triple < kene-length] [
    make-kene-triple
    set recent-triple recent-triple + 1
  ]  
  
  
end
;
;
;
to make-kene-triple
  let research-direction random number-of-research-directions
  let capabilities random number-of-capabilities
  let abilities random-float number-of-abilities
  let expertise number-of-start-expertise
  let new-triple []
  set new-triple (sentence research-direction capabilities abilities  expertise)
  set kene lput new-triple kene
end
;
;
;
to make-research-project
  let project-length 4
  let counter 0
  let kene-length length kene
  while [counter < project-length] [
    let kene-part random kene-length
    if not member? kene-part research-project  [
      set research-project lput kene-part research-project
      set counter length research-project
    ]
  ]
  set research-project sort-by [?1 < ?2] research-project
  
 
  
end
;
;
;
to create-the-big-agents
  create-big-agents                 number-of-big-agents-firms                                [set members [] set kind "firm" initialize-big-agents]
  create-big-agents                 number-of-big-agents-research-institutes                  [set members [] set kind "research-institute" initialize-big-agents]  
end
;
;
;
to initialize-big-agents 
let this-kind kind
  repeat number-of-members-big-agent - length members [
    ask one-of institutes with [kind = this-kind and not big-agent-component?] [set big-agent-component? true set big-agent-ID myself set [members] of myself lput self [members] of myself]
    ]
  set capital reduce [?1 + ?2] map [[capital] of ?] members
end
;
;
;
to go-n-times
  repeat Times-to-run 
  [go-normal]
end
;
;
;
to go-normal
  
  go
  
  ;plot-graphs
  ;export-variables
end
;
;
;
to go-montecarlo
 set current-run-number 1
  setup-normal
  Open-File
  Write-File-Information1
  Export-Variables-Names
  Close-File
  while [number-of-runs >= current-run-number]
  [
  if not (current-run-number = 1)
  [setup-montecarlo]
  ;set pause false
    repeat steps-of-each-run [
      ;; possibility for an if condition for changeing some variables in every run in the x-st Periode
      go-X-Run
    ]
  if (file-exists? (word absolute-save-path "/" "world"  "/" current-run-number ".csv"))
    [file-delete (word absolute-save-path "/" "world"  "/" current-run-number ".csv")]
  let dummy (word absolute-save-path "/" "world" )
  if ((filemanagement:mkdir dummy) =  "error") [show "fehler beim Verzeichnisserstellen" stop]
  export-world (word absolute-save-path "/" "world"  "/" current-run-number ".csv")
  set current-run-number (current-run-number + 1)
  ]
  Write-File-Information2
  

end
;
;
;
to go-X-Run
  go
  Export-Variables
end
;
;
;
to go
  ;show "neue periode"
  set current-activity "finding partners for the proposals" wait 0.1
  clear-values
  pay-taxes                  ;done
  agents-start-ups
  find-partner               ;done

  
  set current-activity "research and evaluation" wait 0.1
  evaluate-proposal          ;done
  aktualise-network-1
  
  group-research             ;done
  evaluate-groupresearch
  pay-funds                  ;done
  evaluate-projects          ;done
  private-research           ;done
  
  
  set current-activity "periode updates" wait 0.1
  agents-exit                ;done
  agents-kene-updte          ;done
  agents-research-project-update
  
  
  do-plotting
  do-export
  
  variable-update
  move-agents
  
  aktualise-network-2
  agents-start-ups
  set current-activity "periode done" wait 0.1
  set period period + 1
end
;
;
;
to pay-taxes
  ask institutes with [ kind = "firm" ]                 [set capital capital - tax]
  ask institutes with [ kind = "university" ]           [set capital capital - tax]
  ask institutes with [ kind = "research-institute" ]   [set capital capital - tax]  
end
;
;
;
to clear-values
  set current-output-of-all-projects [] 
  set current-Connectivity-of-all-institutes []
  set number-of-accepted-proposals-con Acceptred-proposals-conservative
  set number-of-accepted-proposals-rad Accepted-proposals-progressive
  set Duration-of-projects-minimum-value Minimum-periods-of-projects
  set Random-term-duration-Projects Maximum-periods-of-projects - Minimum-periods-of-projects + 1
  set minimum-value-for-edges-internal minimum-value-for-edges
end
;
;
;
to find-partner
  ask institutes           [if (number-of-current-proposals < max-current-proposals and number-of-all-projects < max-all-projects)
                            [set network sort-by [item 1 ?2 < item 1 ?1] network  ; Network: [[Institute Value] ... ]
                            set possible-partners find-candidates
                            set-partners
                            ]
                          ] 
end
;
;
;
to-report find-candidates
  let candidate 0
  let candidates 0
  let network-place 0
  set candidates []
  set network-place 0
  let network-length length network
  while [network-place < network-length and item 1 item network-place network >= 1] [
    if [number-of-current-proposals < max-current-proposals and number-of-all-projects < max-all-projects] of item 0 item network-place network and matches-partner? current-search-strategy self item 0 item network-place network
      [set candidates lput item 0 item network-place network candidates]
    set network-place network-place + 1
  ]
  while [length candidates > percentage-of-prefered-partners] [
    set candidates butlast candidates
  ]
  let rcounter1 0
  while [length candidates < maximum-candidates and rcounter1 < search-forup-to-?-random-candidates] 
    [let random-number random 99 
    ifelse random-number < 33 
      [set candidate ad-candidate "firm" candidates 
      ifelse candidate != -1 
        [set candidates lput candidate candidates] 
        [set rcounter1 rcounter1 + 1]
      ]
      [ifelse random-number < 66
        [set candidate ad-candidate "university" candidates 
        ifelse candidate != -1 
          [set candidates lput candidate candidates] 
          [set rcounter1 rcounter1 + 1]
        ]
        [set candidate ad-candidate "research-institute" candidates 
        ifelse candidate != -1 
          [set candidates lput candidate candidates] 
          [set rcounter1 rcounter1 + 1]
        ]
      ]
    ]
    report candidates
end
;
;
;
to-report ad-candidate [source candidates]
      let candidate-not-found true
      let random-candidate -1
      let candidate-in-network-list false
      let candidate-position-in-network-list -1
      let rcounter 0 
      while [rcounter < 10 and candidate-not-found] 
        [set random-candidate one-of institutes with [kind = source]
        set candidate-in-network-list false  
        if not member? random-candidate candidates and random-candidate != self
          [set candidate-in-network-list false 
          foreach network 
            [if item 0 ? = random-candidate 
              [set candidate-in-network-list true 
              set candidate-position-in-network-list position ? network
              if item 1 item candidate-position-in-network-list network >= minimum-cooperation-value
                [if [number-of-current-proposals < max-current-proposals and number-of-all-projects < max-all-projects] of random-candidate and matches-partner? current-search-strategy self random-candidate
                  [report random-candidate  set candidate-not-found false]
                ]
              ]
            ]
          if not candidate-in-network-list
            [if [number-of-current-proposals < max-current-proposals and number-of-all-projects < max-all-projects] of random-candidate and matches-partner? current-search-strategy self random-candidate
              [report random-candidate  set candidate-not-found false]
            ]
          ] 
        set rcounter rcounter + 1
        ]
     report -1
end
;
;
;
; a partner matches a search strategy if shortest distance and the longest distance between all kene elements are in the
; for the strategy satisfying range
to-report matches-partner? [strategy turtle1 turtle2]
 if [big-agent-component?] of  turtle1 [if [big-agent-component?] of  turtle2 [if [big-agent-ID] of turtle1 = [big-agent-ID] of turtle2 [report false]]]
 let all-distances[]
 let ID-turtle2 turtle2
 let length-research-project-turtle2 length [research-project] of ID-turtle2
 let rcounter2 0
 foreach research-project
   [set rcounter2 0
   while [rcounter2 < length-research-project-turtle2]
     [
     set debug-1 id-turtle2
     set all-distances lput calculate-distance item ? kene item (item rcounter2 [research-project] of ID-turtle2) [kene] of ID-turtle2 all-distances
     set rcounter2 rcounter2 + 1
     ]
   ;set all-distances remove 0 all-distances
   ] 
 let number-of-distances length all-distances
 ;set all-distances sort-by [?1 < ?2] all-distances
 if strategy = "conservative"
   [;ifelse min all-distances <= maximum-value-short-distance-cons and max all-distances <= maximum-value-long-distance-cons 
   let percentage-in-short-border (length filter [? <= border-short-distance-cons] all-distances) / number-of-distances
   let percentage-in-log-border (length filter [? >= border-long-distance-cons] all-distances) / number-of-distances 
   ifelse percentage-in-short-border >= percentage-short-distance-cons and percentage-in-log-border <= percentage-long-distance-cons
     [report true]
     [report false]
   ]
 if strategy = "progressive"
   [;ifelse min all-distances >= minimum-value-short-distance-prog and max all-distances >= minimum-value-long-distance-prog 
   let percentage-in-short-border (length filter [? <= border-short-distance-prog] all-distances) / number-of-distances
   let percentage-in-log-border (length filter [? >= border-long-distance-prog] all-distances) / number-of-distances      
   ifelse percentage-in-short-border <= percentage-short-distance-prog and percentage-in-log-border >= percentage-long-distance-prog
     [report true]
     [report false]
   ]
end
;
; 
;
to-report calculate-distance [triple1 triple2]
  let the-distance 0
  set the-distance ((abs (item 0 triple1 - item 0 triple2)) * distance-wight-research-directions) + ((abs (item 1 triple1 - item 1 triple2)) * distance-wight-capabilities) + ((abs (item 2 triple1 - item 2 triple2)) * distance-wight-abilities)
  report the-distance
end
;
;
;
to set-partners 
  ifelse with-big-projects and random-float 1 < percentage-of-big-projects 
    [set number-of-partners-min-use number-of-partners-min-big
    ifelse variable-projec-length
      [set number-of-partners-max-use number-of-partners-min-big + random number-of-partners-max-big-rnd]
      [set number-of-partners-max-use number-of-partners-min-big ]
    ]
    [set number-of-partners-min-use number-of-partners-min
    ifelse variable-projec-length
      [set number-of-partners-max-use number-of-partners-min + random number-of-partners-max-rnd]
      [set number-of-partners-max-use number-of-partners-min]
    ]
  let current-partners 0
  let rcounter3 0
  let all-locations []
  set all-locations lput location all-locations
  without-interruption 
    [while [number-of-partners-max-use > current-partners and rcounter3 < length possible-partners]
      [if [number-of-current-proposals < max-current-proposals] of item rcounter3 possible-partners
        ;[ifelse with-location
          [let make-partner true
          if with-location and (number-of-different-locations - length all-locations >= number-of-partners-max-use - current-partners)
            [if ( member? [location] of item rcounter3 possible-partners all-locations) [set make-partner false] ]
          if [big-agent-component?] of item rcounter3 possible-partners
            [foreach partners [
              if [big-agent-component?] of ? [
                if [big-agent-component?] of item rcounter3 possible-partners [
                  if [big-agent-ID] of ? = [big-agent-ID] of item rcounter3 possible-partners [
                    set make-partner false]
                  ]
                ]
              ]
            ]
          if make-partner [
            set partners lput item rcounter3 possible-partners partners 
            set all-locations remove-duplicates lput [location] of item rcounter3 possible-partners all-locations
            set current-partners current-partners + 1
            ]
          ] 

        ;]
      set rcounter3 rcounter3 + 1
      ]
    let location-rule-applayed true 
    if with-location 
      [if length all-locations < number-of-different-locations [set location-rule-applayed false]
      ]
    ifelse number-of-partners-min-use <= current-partners and location-rule-applayed
      [set number-of-current-proposals number-of-current-proposals + 1
      set proposal-partners lput partners proposal-partners
      foreach partners
        [ask  ?
          [set number-of-current-proposals number-of-current-proposals + 1
          set proposal-partners lput (remove  self sentence myself [partners] of myself) proposal-partners
          ]
        ]
       make-proposal
      ]
      [set partners[]]
    ]
end
;
;
;
to make-proposal
  hatch-proposal-groups 1 
    [set hidden? true
    set members sentence  myself [partners] of myself
    set research-strategy-of-proposal [current-search-strategy] of myself
    foreach members [ask ? [set all-proposals lput myself all-proposals]]
    set kene []
    foreach members 
      [let rcounter5 0
      let rcounter6 0
      let current-turtle  ?
      while [rcounter5 < number-of-kene-triples-from-research-project and rcounter5 < length [research-project] of current-turtle and rcounter6 < 10]
        [let random-triple sentence ? item one-of [research-project] of current-turtle [kene] of current-turtle
        if not member? random-triple kene
          [set kene lput random-triple kene
          set rcounter5 rcounter5 + 1
          ]
        set rcounter6 rcounter6 + 1
        ]
      set rcounter5 0
      set rcounter6 0
      while [rcounter5 < number-of-kene-triples-from-kene and rcounter5 < length [kene] of current-turtle - number-of-kene-triples-from-research-project and rcounter6 < 10]
        [let random-triple sentence ? one-of  [kene] of current-turtle
        if not member? random-triple kene
          [set kene lput random-triple kene
          set rcounter5 rcounter5 + 1
          ]
        set rcounter6 rcounter6 + 1
        ]
      ]
    let proposal-capabilities []
    foreach kene [set proposal-capabilities lput  item 2  ? proposal-capabilities]
    set number-of-proposal-capabilities remove-duplicates proposal-capabilities
    set number-of-proposal-capabilities map [? / 10] proposal-capabilities
    set number-of-proposal-capabilities map [round ?] proposal-capabilities
    set number-of-proposal-capabilities length remove-duplicates proposal-capabilities
    ]
  
  
end
;
;
;
to evaluate-proposal
  set current-proposals-formulated count proposal-groups
  let proposals-to-evaluate []
  ask proposal-groups [set proposals-to-evaluate lput (sentence self number-of-proposal-capabilities) proposals-to-evaluate]
  set proposals-to-evaluate sort-by [item 1 ?1 < item 1 ?2] proposals-to-evaluate
  ifelse length proposals-to-evaluate <= (number-of-accepted-proposals-con + number-of-accepted-proposals-rad)
    [ask proposal-groups [start-project foreach members [set [all-proposals] of ? remove self [all-proposals] of ?] die]]
    [let increment 0
    repeat number-of-accepted-proposals-con 
      [ask  item 0 item increment proposals-to-evaluate 
        [start-project 
        foreach members [set [all-proposals] of ? remove self [all-proposals] of ?] die]
      set increment increment + 1]
    set increment 1                                     ; 1 because of the difference between length and item
    repeat number-of-accepted-proposals-rad 
      [ask item 0 item (length proposals-to-evaluate - increment) proposals-to-evaluate 
        [start-project 
        foreach members [set [all-proposals] of ? remove self [all-proposals] of ?] die]
      set increment increment + 1]
    ]
end
;
;
;
to start-project
  hatch-projects 1 
    [set hidden? true
    set current-work []
    set this-project self
    set total-successful-work-value 0
    set age 0
    set previous-work []
    set project-duration random Random-term-duration-Projects + Duration-of-projects-minimum-value
    set kene [kene] of myself
    set research-strategy-of-project [research-strategy-of-proposal] of myself
    let kene-dummy []
    foreach kene 
      [ask item 0 ? [set kene-dummy lput (sentence item 0 ? position but-first ? [kene] of item 0 ?) kene-dummy ]]
    set kene kene-dummy 
    set members [members] of myself
    foreach kene 
      [ask item 0 ?
        [if (not member? item 1 ? research-project) [set research-project lput item 1 ? research-project]]; show item 1 ?]
      ]
    ]
    foreach members 
      [set [all-projects] of ? lput this-project [all-projects] of ?
      set [number-of-all-projects] of ? ([number-of-all-projects] of ? + 1)
      set [number-of-current-proposals] of ? ([number-of-current-proposals] of ? - 1)]
    foreach members     ; a successful started project increses the network value of the partners
     [let rcounter7 0
     repeat length members
      [if item rcounter7 members != ? 
        [ifelse member? true map [member? item rcounter7 members ?] [network] of ?
        [set [network] of ? replace-item position true map [member? item rcounter7 members ?] [network] of ? [network] of ? (sentence item 0 item position true map [member? item rcounter7 members ?] [network] of ?  [network] of ? (item 1 item position true map [member? item rcounter7 members ?] [network] of ?  [network] of ? + positive-proposal-increment))]
        [set [network] of ? lput (sentence item rcounter7 members (1 + positive-proposal-increment)) [network] of ?]
        ]
      set rcounter7 rcounter7 + 1
      ]
     ]
end
;
;
;
to aktualise-network-1
  without-interruption [
  ask proposal-groups ; an unsuccessful started project decreses the network value of the partners
    [foreach members     
     [let rcounter8 0
     repeat length members
      [if item rcounter8 members != ? 
        [ifelse member? true map [member? item rcounter8 members ?] [network] of ?
        [set [network] of ? replace-item position true map [member? item rcounter8 members ?] [network] of ? [network] of ? (sentence item 0 item position true map [member? item rcounter8 members ?] [network] of ? [network] of ? ( item 1 item position true map [member? item rcounter8 members ?] [network] of ? [network] of ? + negative-proposal-increment))]
        [set [network] of ? lput (sentence item rcounter8 members (1 + negative-proposal-increment)) [network] of ?]
        ]
      set rcounter8 rcounter8 + 1
      ]
     set [number-of-current-proposals] of ? ([number-of-current-proposals] of ? - 1)
     set [all-proposals] of ? remove self [all-proposals] of ?
     ]
    die]
  ]
end
;
;
;
to private-research
  ask institutes with [length all-projects < 1] [
    let kene-item-to-modyfy one-of kene
    let position-kene-item-to-modyfy position kene-item-to-modyfy kene 
    let random-number random 99
    let direction-to-modyfy one-of ["up" "down"]
    if random-number < 40          ; modyfy KO
      [if direction-to-modyfy = "up"
        [ifelse item 0 kene-item-to-modyfy <= number-of-research-directions - 1
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 0 kene-item-to-modyfy (item 0 kene-item-to-modyfy + 1))]
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 0 kene-item-to-modyfy (item 0 kene-item-to-modyfy - 1))]
        ]
       if direction-to-modyfy = "down"
        [ifelse item 0 kene-item-to-modyfy >=  1
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 0 kene-item-to-modyfy (item 0 kene-item-to-modyfy - 1))]
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 0 kene-item-to-modyfy (item 0 kene-item-to-modyfy + 1))]
        ]
      ]
    if random-number > 39 and random-number < 80        ; modyfy A
      [if direction-to-modyfy = "up"
        [ifelse item 0 kene-item-to-modyfy <= number-of-abilities - 1
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 2 kene-item-to-modyfy (item 2 kene-item-to-modyfy + 1))]
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 2 kene-item-to-modyfy (item 2 kene-item-to-modyfy - 1))]
        ]
       if direction-to-modyfy = "down"
        [ifelse item 0 kene-item-to-modyfy >=  1
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 2 kene-item-to-modyfy (item 2 kene-item-to-modyfy - 1))]
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 2 kene-item-to-modyfy (item 2 kene-item-to-modyfy + 1))]
        ]
      
      ]
    if random-number > 79                               ; modyfy C
      [if direction-to-modyfy = "up"
        [ifelse item 0 kene-item-to-modyfy <= number-of-capabilities - 1
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 1 kene-item-to-modyfy (item 1 kene-item-to-modyfy + 1))]
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 1 kene-item-to-modyfy (item 1 kene-item-to-modyfy - 1))]
        ]
       if direction-to-modyfy = "down"
        [ifelse item 0 kene-item-to-modyfy >=  1
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 1 kene-item-to-modyfy (item 1 kene-item-to-modyfy - 1))]
          [set kene replace-item position-kene-item-to-modyfy kene (replace-item 1 kene-item-to-modyfy (item 1 kene-item-to-modyfy + 1))]
        ]
      
      ]
    if (not  member? position-kene-item-to-modyfy research-project) [
      set research-project remove-item random length research-project research-project ;hier wird ein zufälliger entfernt [kann leider auch aus project sein] abändern
      set research-project lput position-kene-item-to-modyfy research-project
    ]
  ]
  
  
end
;
;
;
to group-research
  ask projects 
    [let number-of-kene-elements (random 3) + 4
    while [number-of-kene-elements > length kene] 
      [set number-of-kene-elements (random 3) + 4]
    set current-work []
    let kene-element-to-add []
    while [length current-work < number-of-kene-elements]
      [set kene-element-to-add one-of kene
      if (not member? kene-element-to-add current-work) 
        [set current-work lput kene-element-to-add current-work]
      ]
    ] 
end
;
;
;
to evaluate-groupresearch
  ask projects 
    [set age age + 1
    evaluate-current-groupresearch
    
    ]
end
;
;
;
to evaluate-current-groupresearch
    let list-of-partners []
    foreach current-work                                                   ; collecting the id's of all participants in the current-work
      [set list-of-partners lput item 0 ? list-of-partners]
    set list-of-partners remove-duplicates list-of-partners            ; removing the dubble collected data
    let number-of-partners length list-of-partners                       ; calculating the number of all participants in the current-work
    let past-experience-of-participants []
    let rcounter8 0
    foreach list-of-partners                                             ; summing up the past experience between the partners of the current-work
      [let rcounter9 0
      repeat (length list-of-partners)
        [if rcounter8 != rcounter9
          [ask ? [set past-experience-of-participants lput (item 1 item (position true map [member? item rcounter9 list-of-partners ?] network) network) past-experience-of-participants]]
        set rcounter9 rcounter9 + 1
        ]
      set rcounter8 rcounter8 + 1
      ]
    let mean-experience-of-participants 1
    ifelse length past-experience-of-participants = 0
      [set mean-experience-of-participants 1]
      [set mean-experience-of-participants reduce [?1 + ?2] past-experience-of-participants / length past-experience-of-participants]
    let all-distances-current-work []
    let rcounter10 0
    let rcounter11 0      
    foreach current-work
      [set rcounter11 0
      repeat ((length current-work))
        [if rcounter10 < rcounter11
          ;[set all-distances-current-work lput (calculate-distance (item (item 1 ?) [kene] of item 0 ?) (item (item rcounter11 item 1 current-work) [kene] of item rcounter11 item 0 current-work)) all-distances-current-work]
          [set all-distances-current-work lput (calculate-distance (item (item 1 ?) [kene] of item 0 ?) (item (item 1 (item rcounter11 current-work)) [kene] of item 0 (item rcounter11 current-work))) all-distances-current-work]
        set rcounter11 rcounter11 + 1
        ]
      set rcounter10 rcounter10 + 1
      ]
    let max-distance-current-work max all-distances-current-work
    let min-distance-current-work min all-distances-current-work
    let all-expertises-current-work []
    foreach current-work
      [set all-expertises-current-work lput (item 3 item (item 1 ?) [kene] of item 0 ?) all-expertises-current-work]
    let mean-all-expertises-current-work reduce [?1 + ?2] all-expertises-current-work / length all-expertises-current-work
    let type-of-current-work 0
    let location-weight 1
    if with-distance-wigth 
      [set location-weight []
      let rcounter1d 0
      foreach list-of-partners
        [set rcounter1d 0
        repeat length list-of-partners 
          [if ? != item rcounter1d list-of-partners
            [(ask ? [set location-weight lput  distance item rcounter1d list-of-partners  location-weight])]
          set rcounter1d rcounter1d + 1
          ]
        ]
      set location-weight mean location-weight
      set location-weight location-weight / sqrt (max-pxcor ^ 2 + max-pycor ^ 2 ) / max-pxcor
      ]
      
   
    if (research-strategy-of-project = "conservative")
      [set type-of-current-work ((min-distance-current-work / maximum-value-short-distance-cons) * (4 / 9) + (max-distance-current-work / maximum-value-long-distance-cons) * (2 / 9) + random-float (1 / 3))
      ifelse (mean-all-expertises-current-work / 4 * sqrt (mean-experience-of-participants) > random-poisson (20 / 4) + (random (25 / 4)) * (min-distance-current-work / maximum-value-short-distance-cons ) * location-weight)
        [successful-current-work type-of-current-work list-of-partners         
        learn-form-project type-of-current-work list-of-partners]
        [unsuccessful-current-work type-of-current-work list-of-partners]    
      ]
    let maximum-distance-value (number-of-research-directions * distance-wight-research-directions + number-of-capabilities * distance-wight-capabilities + number-of-abilities * distance-wight-abilities)
    
    if (research-strategy-of-project = "progressive")
      [set type-of-current-work ((min-distance-current-work / (maximum-distance-value - minimum-value-short-distance-prog)) * (2 / 9)) + ((max-distance-current-work / (maximum-distance-value - minimum-value-long-distance-prog) * (4 / 9)) + random-float (1 / 3))
      ifelse (mean-all-expertises-current-work / 4 * sqrt (mean-experience-of-participants) > random-poisson (20 / 4) + (random 25 / 4) * (min-distance-current-work / (maximum-distance-value - minimum-value-short-distance-prog)) * location-weight)
        [successful-current-work type-of-current-work list-of-partners          
        learn-form-project type-of-current-work list-of-partners]
        [unsuccessful-current-work type-of-current-work list-of-partners]      
      ]  
end
;
;
;
to learn-form-project [type-of-current-work list-of-partners]
  let new-kene []
  foreach list-of-partners [
    if type-of-current-work > random-float 2 [
      set new-kene one-of current-work
      if item 0 new-kene != ? [
        ask ? [
          if not member? item item 1 new-kene [kene] of item 0 new-kene kene
            [set kene lput item item 1 new-kene [kene] of item 0 new-kene kene]
        ]
      ]
    ]
  ]
end
;
;
;
to successful-current-work [type-of-current-work list-of-partners]
  set total-successful-work-value total-successful-work-value + (Exp (type-of-current-work) - 1)
  let rcounter12 0
  foreach list-of-partners 
    [let rcounter13 0
    repeat length list-of-partners
      [if rcounter12 != rcounter13
        [ask ? 
          [set network replace-item position true map [member? item rcounter13 list-of-partners ?] network network (sentence item 0 item position true map [member? item rcounter13 list-of-partners ?] network  network (item 1 item position true map [member? item rcounter13 list-of-partners ?] network network + ((Exp (type-of-current-work) - 1) / 10)))]
        ]
      set rcounter13 rcounter13 + 1
      ]
    set rcounter12 rcounter12 + 1
    ]
   let list-dummy []
   set list-dummy lput 1                     list-dummy
   set list-dummy lput current-work          list-dummy
   set list-dummy lput list-of-partners      list-dummy
   set list-dummy lput type-of-current-work  list-dummy
   ;set previous-work lput (sentence 1 current-work list-of-partners type-of-current-work) previous-work    
   set previous-work lput list-dummy previous-work 
   set current-output-of-all-projects lput type-of-current-work current-output-of-all-projects  ;for plotting of successful work
end
;
;
;
to unsuccessful-current-work [type-of-current-work list-of-partners]
  let rcounter14 0
  foreach list-of-partners 
    [let rcounter15 0
    repeat length list-of-partners
      [if rcounter14 != rcounter15
        [ask ? 
          [set network replace-item position true map [member? item rcounter15 list-of-partners ?] network network (sentence item 0 item position true map [member? item rcounter15 list-of-partners ?] network  network (item 1 item position true map [member? item rcounter15 list-of-partners ?] network network - ((Exp (type-of-current-work) - 1) / 30)))]
        ]
      set rcounter15 rcounter15 + 1
      ]
    set rcounter14 rcounter14 + 1
    ]
   let list-dummy []
   set list-dummy lput 0                     list-dummy
   set list-dummy lput current-work          list-dummy
   set list-dummy lput list-of-partners      list-dummy
   set list-dummy lput type-of-current-work  list-dummy
   ;set previous-work lput (sentence 0 current-work list-of-partners type-of-current-work) previous-work     
   set previous-work lput list-dummy previous-work 
   
end
;
;
;
to pay-funds
  ask projects 
    [foreach members 
      [ask ? [set capital capital + project-revenue]]
    ] 
end
;
;
;
to evaluate-projects
  ask projects with [age = project-duration]
    [ifelse total-successful-work-value < project-duration * 0.1              ; threshhold for an positiv network bindig for the hole project
      [benefit-from-project members (- 0.05)]
      [ifelse total-successful-work-value < project-duration * 0.5
        [benefit-from-project members  0.25]
        [ifelse total-successful-work-value < project-duration 
          [benefit-from-project members  0.5]
          [ifelse total-successful-work-value < project-duration * 1.3
          [benefit-from-project members  0.75]
          [benefit-from-project members  1]
          ]
        ]
      ]
    foreach members
      [set [all-projects] of ? remove self [all-projects] of ?
      set [number-of-all-projects] of ? [number-of-all-projects] of ? - 1
      ]  
    die  
    ]  
end
;
;
;
to benefit-from-project [list-of-institutes network-value]
  let rcounter16 0
  foreach list-of-institutes 
    [let rcounter17 0
    repeat length list-of-institutes
      [if rcounter16 != rcounter17
        [ask ? 
          [set network replace-item position true map [member? item rcounter17 list-of-institutes ?] network network (sentence item 0 item position true map [member? item rcounter17 list-of-institutes ?] network  network (item 1 item position true map [member? item rcounter17 list-of-institutes ?] network network + network-value))]
        ]
      set rcounter17 rcounter17 + 1
      ]
    set rcounter16 rcounter16 + 1
    ]
end
;
;
;
to agents-exit
  ask institutes                 [if capital < 0 [agent-die]]  
end
;
;
;
to agent-die
  without-interruption [foreach network [ask  item 0 ? [set network filter [item 0 ? != myself] network]]]
  if big-agent-component? [ask big-agent-ID [set members remove myself members]]
  die
end
;
;
;
to agents-kene-updte
  ask institutes            [without-interruption  [
                              set kene-counter 0 
                              foreach kene [
                                ifelse not member? kene-counter research-project  ; expand for proposal
                                  [reduce-expertise]
                                  [gain-expertise]
                                ifelse item 3 ? <= 1 and not member? kene-counter research-project; Because the not updated value is in the memory => not 0 ?? but ih update?
                                  [forget-triple kene-counter] 
                                  [set kene-counter kene-counter + 1]
                              ] 
                            ]]   
end
;
;
;
to reduce-expertise
  set kene replace-item kene-counter kene replace-item 3 item kene-counter kene ((item 3 item kene-counter kene) - 1)
end
;
;
;
to gain-expertise
  if item 3 item kene-counter kene < 40 [set kene replace-item kene-counter kene replace-item 3 item kene-counter kene ((item 3 item kene-counter kene) + 1)]
end
;
; 
;
to forget-triple [kene-to-forget]
  set kene remove-item kene-to-forget kene
  ;if member? kene-counter research-project [set research-project remove kene-counter research-project]
  foreach research-project [if ? > kene-to-forget [set research-project replace-item (position ? research-project) research-project (? - 1)]]
  let rcounter30 0
  foreach all-projects
    [ask ?
      [set rcounter30 0
      foreach kene
        [
        ;show "Ursprung"
        ;show myself
        ;show "Project"
        ;show self
        ;show "kene"
        ;show kene
        ;show "kene-to-forget"
        ;show kene-to-forget
        ;show "rcounter"
        ;show rcounter30
        ;show "kene item (?)"
        ;show ?
        ;show "item 0 ?"
        ;show item 0 ?
        
        
        if item 0 ? = myself and item 1 ? > kene-to-forget
          [set kene replace-item rcounter30 kene (sentence item 0 ? (item 1 ? - 1))]
        set rcounter30 (rcounter30 + 1)
        
        ;show "Kene item ?"
        ;show ?
        ;show "kene item direkt"
        ;show item (rcounter30 - 1) kene
        ;show "kene nachher"
        ;show kene
        ]
      ;;
      let rcounter31 0
      let change-previous-work false
      foreach previous-work
        [let current-item-of-previous-work ?
        let current-work-of-item-of-previous-work item 1 ?
        let change-item-of-previos-work false
        foreach current-work-of-item-of-previous-work
          [let rcounter32 0
          if (item 0 ? = myself and item 1 ? > kene-to-forget)
            [set change-previous-work true
            set change-item-of-previos-work true
            set current-work-of-item-of-previous-work replace-item rcounter32 current-work-of-item-of-previous-work (sentence item 0 ? (item 1 ? - 1))]
          set rcounter32 rcounter32 + 1]
        if change-item-of-previos-work
          [set current-item-of-previous-work replace-item 1 current-item-of-previous-work current-work-of-item-of-previous-work
          set previous-work replace-item rcounter31 previous-work current-item-of-previous-work
          set change-previous-work false]
        set rcounter31 rcounter31 + 1]
      ]
    ]  
end
;
;
;
to agents-research-project-update
  
  
  
end
;
;
;
to do-plotting
  set-current-plot "Number of Proposals"
  set-current-plot-pen "Proposals"
  plot current-proposals-formulated
  set-current-plot "Number of Projects"
  set-current-plot-pen "Projects"
  plot Number-of-current-projects
  set-current-plot "Output Projects"
  set-current-plot-pen "Output"  
  histogram current-output-of-all-projects
  set current-number-of-institutes count institutes
  
end
;
;
;
to variable-update
  ask institutes [ 
      set partners []
      set age age + 1
       
    ]
  ask big-agents [set capital reduce [?1 + ?2] map [[capital] of ?] members]
  set Number-of-current-projects count projects
end
;
;
;
to agents-start-ups
  if count institutes with [kind = "firm"] < number-of-start-firms [create-institutes number-of-start-firms - count institutes with [kind = "firm"] [initialise-firms]]
  if count institutes with [kind = "university"] < number-of-start-universities [create-institutes number-of-start-universities - count institutes with [kind = "university"] [initialise-universities]]  
  if count institutes with [kind = "research-institute"] < number-of-start-research-institutes [create-institutes  number-of-start-research-institutes - count institutes with [kind = "research-institute"] [initialise-research-institutes] ]  
  ask big-agents with [length members < number-of-members-big-agent] [initialize-big-agents ]
end
;
;
;
to move-agents
  
  
  
end
;
;
;
to aktualise-network-2
  without-interruption [ ask institutes [
    let all-project-partners []
    if length network > 0 [
    if min map [item 1 ?] network < 1 [
      foreach all-projects [ask ? [set all-project-partners sentence members all-project-partners]]
      set all-project-partners remove-duplicates all-project-partners
      ;show all-project-partners
      ]]
    let rcounter40 0
    foreach network [
      ;show self
      ;show ?
      ;show item rcounter40 network
      ifelse item 1 ? > 1.1
        [set network replace-item rcounter40 network (sentence item 0 item rcounter40 network ( item 1 item rcounter40 network * (1 - time-increment-network-value)))
        ;show item rcounter40 network show " reduce"
        ]
        [ifelse item 1 ? < 0.95
          [set network replace-item rcounter40 network (sentence item 0 item rcounter40 network ( item 1 item rcounter40 network * (1 + time-increment-network-value / 2)))
          ;show item rcounter40 network show "increase"
          ]
          [ifelse item 1 ? < 1 and not member? item 0 ? all-project-partners [
            ;show self 
            ;show all-project-partners
            ;show item rcounter40 network show "remove" 
            set network remove-item rcounter40 network set rcounter40 rcounter40 - 1]
            [set network replace-item rcounter40 network (sentence item 0 item rcounter40 network (1))]
          ]
        ]
    set rcounter40 rcounter40 + 1
    ]    
  ]]


  

end
;
;
;
to do-export
  if Export-Data [
    prepare-export
    if Export-adjacency-matrix [write-adjacency-matrix-Networks]
    if Export-pajek-adjacency-matrix [pajek-write-adjacency-matrix-Networks]
    if Export-bipartite-adjacency-matrix [bipartite-write-adjacency-matrix-Networks]
  ]
end
;
;
;
to prepare-export
  ask institutes [
    set Positive-network-bindings []
    foreach network [if item 1 ? > minimum-value-for-edges-internal [set Positive-network-bindings lput item 0 ? Positive-network-bindings]]
  ]
  set institute-list []
  ask institutes [set institute-list lput self institute-list]
  let institute-list-component filter [ [big-agent-component?] of ?] institute-list
  foreach institute-list-component [set institute-list remove ? institute-list]
  ask big-agents [set institute-list lput self institute-list]
  set institute-list sort-by [?1 < ?2] institute-list
  set project-list []
  ask projects [set project-list lput self project-list]
  set project-list sort-by [?1 < ?2] project-list
  ask institutes [
    foreach Positive-network-bindings [
      if [big-agent-component?] of ? [
        set Positive-network-bindings remove ? Positive-network-bindings set Positive-network-bindings fput [big-agent-ID] of ? Positive-network-bindings
        ]
      ]
    set Positive-network-bindings remove-duplicates Positive-network-bindings
    ]
  
  
  ask big-agents [
    set Positive-network-bindings []
    foreach members [
      set Positive-network-bindings (sentence Positive-network-bindings [Positive-network-bindings] of ?)
      ]
    set Positive-network-bindings remove-duplicates Positive-network-bindings
    ]
end
;
;
;  
to write-adjacency-matrix-Networks  
  if (file-exists? (word absolute-save-path  "/"  adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  adjacency-matrix-Networks-file-ending))
    [file-delete (word absolute-save-path  "/"  adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  adjacency-matrix-Networks-file-ending)]
  let dummy (word absolute-save-path  "/"  adjacency-matrix-Networks-folder  "/"  current-run-number  "/")
  if ((filemanagement:mkdir dummy) =  "error") [show "fehler beim Verzeichnisserstellen" stop]
  file-open (word absolute-save-path  "/"  adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  adjacency-matrix-Networks-file-ending)


  let counter 0
  foreach institute-list [
    ;file-type ? file-type adjacency-matrix-Networks-separator
    ask ? [ without-interruption [
       foreach institute-list [
         ifelse member? ? Positive-network-bindings ;or ? = Firm-ID-of self           ;; delet the part after or for a diagonal with 0's
           [file-type 1 file-type adjacency-matrix-Networks-separator]
           [file-type 0 file-type adjacency-matrix-Networks-separator]
       ]]
    file-print ""
    ]
  ]
  file-close 
end



to pajek-write-adjacency-matrix-Networks
  let new-line "\r\n"
  if (file-exists? (word absolute-save-path  "/"  pajek-adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  pajek-adjacency-matrix-file-ending))
    [file-delete (word absolute-save-path  "/"  pajek-adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  pajek-adjacency-matrix-file-ending)]
  let dummy (word absolute-save-path  "/" pajek-adjacency-matrix-Networks-folder  "/"  current-run-number  "/")
  if ((filemanagement:mkdir dummy) =  "error") [show "fehler beim Verzeichnisserstellen" stop]
  file-open (word absolute-save-path  "/"  pajek-adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  pajek-adjacency-matrix-file-ending)
  file-type "*vertices" file-type pajek-adjacency-matrix-separator file-type length institute-list file-type new-line
  foreach institute-list [file-type (position ?  institute-list + 1) file-type pajek-adjacency-matrix-separator file-type "\"" file-type ? file-type "\"" file-type pajek-adjacency-matrix-separator file-type (([max-pxcor - xcor] of ?) / (2 * max-pxcor))  file-type pajek-adjacency-matrix-separator file-type (([max-pycor - ycor] of ?) / (2 * max-pycor)) file-type new-line]
;
  file-type "*edges" file-type new-line
  let counter 0
  foreach institute-list [
    ask  ? [ without-interruption [
       foreach institute-list [
         if member? ? Positive-network-bindings            
           [file-type (position self institute-list + 1) file-type pajek-adjacency-matrix-separator file-type (position ?  institute-list + 1) file-type pajek-adjacency-matrix-separator file-type Value-For-Networks file-type new-line]
       ]
    ]]
  ]
  file-close 
end




to bipartite-write-adjacency-matrix-Networks  
  if (file-exists? (word absolute-save-path  "/"  bipartite-adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  adjacency-matrix-Networks-file-ending))
    [file-delete (word absolute-save-path  "/"  bipartite-adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  adjacency-matrix-Networks-file-ending)]
  let dummy (word absolute-save-path  "/"  bipartite-adjacency-matrix-Networks-folder  "/"  current-run-number  "/")
  if ((filemanagement:mkdir dummy) =  "error") [show "fehler beim Verzeichnisserstellen" stop]
  file-open (word absolute-save-path  "/"  bipartite-adjacency-matrix-Networks-folder  "/"  current-run-number  "/"  period  adjacency-matrix-Networks-file-ending)


  let counter 0
  foreach project-list [
    ;file-type ? file-type adjacency-matrix-Networks-separator
    ask ? [ without-interruption [
       foreach institute-list [
         ifelse member? ? members 
           [file-type 1 file-type adjacency-matrix-Networks-separator]
           [file-type 0 file-type adjacency-matrix-Networks-separator]
       ]]
    file-print ""
    ]
  ]
  file-close 
end
;
;
;
to go-scenario
  setup-scenario-file
  let scenario-running true
  let current-run 1
  let current-variables []
  while [scenario-running]
    [set current-variables read-Skein-File-line current-run
    set-skein-file-variables current-variables
    if last current-variables [set scenario-running false]
    repeat item 1 current-variables - item 0 current-variables [go]  
    set current-run current-run + 1
    ]
end
;
;
;
to load-scenario-settings
  let current-variables read-Skein-File-line current-setting
  set-skein-file-variables current-variables
end
;
;
;
to-report read-Skein-File-line [line-to-read]
  file-open scenario-file
  let dummy 0
  repeat line-to-read - 1 [set dummy file-read-line]
  let read-string file-read-line
  
  let continue-parsing true
  let column-unfinished true
  let startposition 0
  let endposition 0
  let length-line length read-string
  let separator ";"
  let list-of-variables []
  
  while [continue-parsing]
    [set column-unfinished true
    while [column-unfinished]
      [ifelse item endposition read-string = separator
        [set list-of-variables lput (read-from-string substring read-string startposition endposition) list-of-variables
        set endposition endposition + 1
        set column-unfinished false]
        [set endposition endposition + 1]
      ]
    set startposition endposition 
    if endposition =  length-line [set continue-parsing false] 
    ]
  set list-of-variables lput file-at-end? list-of-variables
  file-close
  report list-of-variables
end
;
;
;
to set-skein-file-variables [list-of-variables]
  
  
  set  Minimum-periods-of-projects                        item  2 list-of-variables
  set  Kene-share-main-field-f                            item  3 list-of-variables
  set  Kene-share-main-field-r                            item  4 list-of-variables
  set  Kene-share-main-field-u                            item  5 list-of-variables
  set  maximum-candidates                                 item  6 list-of-variables
  set  maximum-value-long-distance-cons                   item  7 list-of-variables
  set  maximum-value-short-distance-cons                  item  8 list-of-variables
  set  minimum-cooperation-value                          item  9 list-of-variables
  set  minimum-value-long-distance-prog                   item 10 list-of-variables
  set  minimum-value-short-distance-prog                  item 11 list-of-variables
  set  negative-proposal-increment                        item 12 list-of-variables
  set  Acceptred-proposals-conservative                   item 13 list-of-variables
  set  Accepted-proposals-progressive                     item 14 list-of-variables
  set  number-of-kene-triples-from-kene                   item 15 list-of-variables
  set  number-of-kene-triples-from-research-project       item 16 list-of-variables
  set  number-of-start-firms                              item 17 list-of-variables
  set  number-of-start-research-institutes                item 18 list-of-variables
  set  number-of-start-universities                       item 19 list-of-variables
  set  percentage-of-prefered-partners                    item 20 list-of-variables
  set  positive-proposal-increment                        item 21 list-of-variables
  set  project-revenue                                    item 22 list-of-variables
  set  Maximum-periods-of-projects                        item 23 list-of-variables
  set  tax                                                item 24 list-of-variables
  set  max-current-proposals-global                       item 25 list-of-variables
  set  max-all-projects-global                            item 26 list-of-variables  
  set  border-short-distance-cons                         item 27 list-of-variables
  set  percentage-short-distance-cons                     item 28 list-of-variables
  set  border-long-distance-cons                          item 29 list-of-variables
  set  percentage-long-distance-cons                      item 30 list-of-variables
  set  border-short-distance-prog                         item 31 list-of-variables
  set  percentage-short-distance-prog                     item 32 list-of-variables
  set  border-long-distance-prog                          item 33 list-of-variables
  set  percentage-long-distance-prog                      item 34 list-of-variables
  set  number-of-big-agents-firms                         item 35 list-of-variables
  set  number-of-big-agents-research-institutes           item 36 list-of-variables
  set  number-of-members-big-agent                        item 37 list-of-variables
  set with-location                                       item 38 list-of-variables
  set number-of-different-locations                       item 39 list-of-variables
  set with-distance-wigth                                 item 40 list-of-variables
  ;set                                  item 41 list-of-variables
  
  
  set Random-term-duration-Projects Maximum-periods-of-projects - Minimum-periods-of-projects + 1 
  
  
end
;
;
;
to Open-File
  if (file-exists? (word absolute-save-path  "/"  Data-file))
    [file-delete (word absolute-save-path  "/"  Data-file)]
  file-open (word absolute-save-path  "/"  Data-file)
  let dummy (word absolute-save-path )
  if ((filemanagement:mkdir dummy) =  "error") [show "fehler beim Verzeichnisserstellen" stop]
end
;
;
;
to Close-File
  file-close 
  ;set Export-Variables false
end
;
;
;
to Write-File-Information1
  ;
  file-type number-of-runs file-type ";"
  ;
  file-type steps-of-each-run file-type ";"
  ;
  file-type Number-of-Export-Variables file-type ";"
  ;
  file-type "\r\n"
end
;
;
;
to Write-File-Information2
  file-open (word absolute-save-path  "/"  Data-file)
  
  Close-File
end
;
;
;
to Export-Variables-Names
  let new-line "\r\n"
  
  file-type "Step;"
  file-type "#-current-output-of-all-projects"  file-type ";"
  file-type "av-current-output-of-all-projects" file-type ";"
  file-type "current-proposals-formulated" file-type ";"
  file-type "Number-of-current-projects" file-type ";"



  file-type new-line
  ;file-print ""
end
;
;
;
to Export-Variables
  
          
  let new-line "\r\n"


  file-open (word absolute-save-path  "/"  Data-file)

  file-type period - 1 file-type ";"
  file-type length current-output-of-all-projects  file-type ";"
  file-type mean current-output-of-all-projects file-type ";"
  file-type current-proposals-formulated file-type ";"
  file-type Number-of-current-projects file-type ";"


  
  file-type new-line
  ;file-print ""
  file-close  
  
end










;

















;
@#$#@#$#@
GRAPHICS-WINDOW
205
10
644
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks

CC-WINDOW
5
484
653
579
Command Center
0

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
