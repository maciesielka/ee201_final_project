

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /card_memory_tb/status
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/CLKA
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/ADDRA
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/DINA
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/WEA
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/DOUTA
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/CLKB
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/ADDRB
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/DINB
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/WEB
      waveform add -signals /card_memory_tb/card_memory_synth_inst/bmg_port/DOUTB

console submit -using simulator -wait no "run"
