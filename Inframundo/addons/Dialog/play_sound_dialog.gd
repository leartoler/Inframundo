extends DefaultDialog

onready var lineedit		= $VBoxContainer/LineEdit
onready var last_used		= $VBoxContainer/HBoxContainer/OptionButton
onready var audio_player	= $AudioStreamPlayer

var sounds_path = []
var paths
var clear_mode = true

signal show_select_audio_file_dialog_request(id)

func _on_Cancel_Button_button_down() -> void:
	emit_signal("Cancel")

func set_path(path):
	lineedit.text = path
	if !sounds_path.has(path):
		sounds_path.append(path)
		fill_sounds_list()

func _on_OK_Button_button_down() -> void:
	var text = {}
	var a = lineedit.text.replace(" ", "■")
	if paths != null:
		a = a.replace(paths.sounds, "")
	if a != "":
		text["begin_text"]	= "[play_sound path=%s]" % a
		text["end_text"]	= ""
	else:
		text = null
	emit_signal("OK", text, dialog_id)


func _on_OptionButton_item_selected(index: int) -> void:
	if index < 1: return
	lineedit.text = sounds_path[index - 1]
	last_used.select(0)
	yield(get_tree(), "idle_frame")
	get_node("VBoxContainer/HBoxContainer3/OK_Button").grab_focus()


func _on_Button_button_down() -> void:
	emit_signal("show_select_audio_file_dialog_request", "sound_01")


func _on_LineEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == 1 and event.is_pressed():
		emit_signal("show_select_audio_file_dialog_request", "sound_01")


func _on_play_sound_dialog_visibility_changed() -> void:
	if visible and lineedit and clear_mode:
		lineedit.text = ""
	else:
		audio_player.stop()
	clear_mode = true


func fill_sounds_list():
	last_used.clear()
	last_used.add_item("last used...")
	for path in sounds_path:
		last_used.add_item(path)
	last_used.select(0)


func _on_AudioStreamPlayer_finished() -> void:
	audio_player.stop()


func _on_TextureButton_button_down() -> void:
	if lineedit.text != "":
		play_sound(lineedit.text)


func play_sound(path):
	if paths == null: return
	if paths != null:
		if path.find(paths.sounds) == -1:
			path = paths.sounds + path
	print(path)
	var res = loadfile(path)
	if res is AudioStream:
		if res is AudioStreamSample:
			res.loop_mode = AudioStreamSample.LOOP_DISABLED
		else:
			res.set_loop(false)
		audio_player.set_stream(res)
		audio_player.play()


func set_parameters(parameters):
	for i in range(0, parameters.size()):
		var param = parameters[i].split("=")
		if param.size() >= 2:
			match param[0]:
				"path" :
					lineedit.text = param[1].replace("■", " ")
					clear_mode = false


# CODE TO LOAD EXTERNAL SOUND   vvvvv


			
#GDScriptAudioImport v0.1

#MIT License
#
#Copyright (c) 2020 Gianclgar (Giannino Clemente) gianclgar@gmail.com
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

#I honestly don't care that much, Kopimi ftw, but it's my little baby and I want it to look nice :3

func loadfile(filepath):
	var file = File.new()
	file.open(filepath, File.READ)
	var bytes = file.get_buffer(file.get_len())

	# if File is wav
	if filepath.ends_with(".wav"):

		var newstream = AudioStreamSample.new()

		#---------------------------
		#parrrrseeeeee!!! :D

		for i in range(0, 100):
			var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
			
			if those4bytes == "RIFF": 
				#print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
				#RIP bytes 4-7 integer for now
				pass
			if those4bytes == "WAVE": 
				#print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))
				pass

			if those4bytes == "fmt ":
				#print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
				
				#get format subchunk size, 4 bytes next to "fmt " are an int32
				var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 32)
				#print ("Format subchunk size: " + str(formatsubchunksize))
				
				#using formatsubchunk index so it's easier to understand what's going on
				var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

				#get format code [Bytes 0-1]
				var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
				var format_name
				if format_code == 0: format_name = "8_BITS"
				elif format_code == 1: format_name = "16_BITS"
				elif format_code == 2: format_name = "IMA_ADPCM"
				#print ("Format: " + str(format_code) + " " + format_name)
				#assign format to our AudioStreamSample
				newstream.format = format_code
				
				#get channel num [Bytes 2-3]
				var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
				#print ("Number of channels: " + str(channel_num))
				#set our AudioStreamSample to stereo if needed
				if channel_num == 2: newstream.stereo = true
				
				#get sample rate [Bytes 4-7]
				var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 32)
				#print ("Sample rate: " + str(sample_rate))
				#set our AudioStreamSample mixrate
				newstream.mix_rate = sample_rate
				
				#get byte_rate [Bytes 8-11] because we can
				var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 32)
				#print ("Byte rate: " + str(byte_rate))
				
				#same with bits*sample*channel [Bytes 12-13]
				var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
				#print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
				#aaaand bits per sample [Bytes 14-15]
				var bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
				#print ("Bits per sample: " + str(bits_per_sample))
				
				
			if those4bytes == "data":
				var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 32)
				#print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

				var data_entry_point = (i+8)
				#print ("Audio data starts at byte " + str(data_entry_point))
				
				newstream.data = bytes.subarray(data_entry_point, data_entry_point+audio_data_size-1)
				
			# end of parsing
			#---------------------------

		#get samples and set loop end
		var samplenum = newstream.data.size() / 4
		newstream.loop_end = samplenum
		newstream.loop_mode = 1 #chage to 0 or delete this line if you don't want loop, also check out modes 2 and 3 in the docs
		return newstream  #:D

	#if file is ogg
	elif filepath.ends_with(".ogg"):
		var newstream = AudioStreamOGGVorbis.new()
		newstream.loop = true #set to false or delet this line if you dont want to loop
		newstream.data = bytes
		return newstream

	else:
		print ("ERROR: Wrong filetype or format")
	file.close()
	
	return false


# ---------- REFERENCE ---------------
# note: typical values doesn't always match

#Positions  Typical Value Description
#
#1 - 4      "RIFF"        Marks the file as a RIFF multimedia file.
#                         Characters are each 1 byte long.
#
#5 - 8      (integer)     The overall file size in bytes (32-bit integer)
#                         minus 8 bytes. Typically, you'd fill this in after
#                         file creation is complete.
#
#9 - 12     "WAVE"        RIFF file format header. For our purposes, it
#                         always equals "WAVE".
#
#13-16      "fmt "        Format sub-chunk marker. Includes trailing null.
#
#17-20      16            Length of the rest of the format sub-chunk below.
#
#21-22      1             Audio format code, a 2 byte (16 bit) integer. 
#                         1 = PCM (pulse code modulation).
#
#23-24      2             Number of channels as a 2 byte (16 bit) integer.
#                         1 = mono, 2 = stereo, etc.
#
#25-28      44100         Sample rate as a 4 byte (32 bit) integer. Common
#                         values are 44100 (CD), 48000 (DAT). Sample rate =
#                         number of samples per second, or Hertz.
#
#29-32      176400        (SampleRate * BitsPerSample * Channels) / 8
#                         This is the Byte rate.
#
#33-34      4             (BitsPerSample * Channels) / 8
#                         1 = 8 bit mono, 2 = 8 bit stereo or 16 bit mono, 4
#                         = 16 bit stereo.
#
#35-36      16            Bits per sample. 
#
#37-40      "data"        Data sub-chunk header. Marks the beginning of the
#                         raw data section.
#
#41-44      (integer)     The number of bytes of the data section below this
#                         point. Also equal to (#ofSamples * #ofChannels *
#                         BitsPerSample) / 8
#
#45+                      The raw audio data. 

