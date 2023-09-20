# sample_ruby_api
Initial: 29 Nov 2019
Ruby API Probability Sampling DishAnyWhere Movies and TV-Shows that 
- Are Missing important fields: Description, Rating, Genre, Network, Image
- Quicker than full DishAnyWhere Movies and TV-Shows search (minutes vs hours)
- Determine best sampling method compare to full search
Results Presented by By Arnold Miller, Sr. SDET (SW QA-Tester)
- Agile Testing & Test Automation Summit; Denver, CO, USA on 19 Dec 2019
  - Sildes: Validate_ML_Stat_Sample_19Dec2019
- ASQ Boulder (Section 1313) Meeting; Boulder, CO; USA on 23 Jan 2020
  - Slides: Simple_vs_Cluster_23Jan2020
Probability Sample Methods
- Simple Random: 600 individual items: Execution Baseline
- Stratified: Start Letter with pro-rated Simple Random individual items
  - 600 items pro-rated via Strata population with minimum 1 per Strata
- Cluster: 60 Simple Random groups of 10. Evaluate all items in group
Non-Probability Sample
- Convenience: First 100 each Sort; First 50 each Genre, View Rating; First 25
each Start Letter

Update: 20 Sep 2023
Gemfile
sample_api ... files with current DishAnyWhere Web and API build versions

DONE
