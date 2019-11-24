# TalzLinuxModManager
(Work in Progress) World of Warcraft bash shell mod manager for Linux

  Talz's Linux Mod Manager is a World of Warcraft AddOn manager written in Bash shell. It queries github for World of Warcraft repositories and then can clone them in a convenient place. TLMM will also update the mods with git pull. I just began working on this so don't expect much yet. Additionally you may find the installmod.sh useful for searching and cloning github repos from the terminal as it doesn't care if it is a WoW AddOn or not. 

TO DO list
  -Work on the installastion function to parse the directories, determine .lua file locations, and synchronize those
   directories into [WOWDIR]/Interface/AddOns. Some mods have several "sub mods" within a larger repository but WoW
   needs them as seperate directories within Interface/AddOns.
  - Possibly seperate databases for retail, classic, and PTR. Right now seperate TLMMs would be deployed for the 
    _retail_ and _classic_ WoW root Interface/AddOns directories. 
    
       -Talzahr, Kel'Thuzad
