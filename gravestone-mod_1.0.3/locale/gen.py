# -*- coding: utf-8 -*-
import os

lang = ["af", "ar", "bg", "ca", "cs", "da", "de", "el", "en", "es-ES", "et", "fi", "fr", "he", "hu", "it",
        "ja", "ko", "lv", "nl", "no", "pl", "pt-BR", "pt-PT", "ro", "ru", "sv-SE", "tr", "uk", "vi", "zh-CN", "zh-TW"]
words = ["Grafsteen", "ضريح", "Надгробна плоча", "Làpida sepulcral", "Náhrobek", "Gravsten", "Grabstein",
         "Ταφόπετρα", "Gravestone", "Lápida sepulcral", "Hauakivi", "Hautakivi", "Pierre tombale", "מצבה", "Sírkő",
         "Pietra sepolcrale", "墓石", "묘비", "Kapakmens", "Grafsteen", "Gravstein", "Nagrobek", "Lápide",
         "Lápide", "Lespede", "Могильная плита", "Gravestone", "Mezar taşı", "Могильна плита", "Bia đá", "墓碑", "墓碑"]

trans = zip(lang, words)

for tran in trans:
    if not os.path.exists(tran[0]):
        os.makedirs(tran[0])
    with open(tran[0] + '/locale.cfg', 'w') as f:
        f.write('[entity-name]\ngravestone = ')
        f.write(tran[1])
        f.write('\n')
