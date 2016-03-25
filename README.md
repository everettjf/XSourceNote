# XSourceNote 

[中文介绍](http://everettjf.github.io/2016/02/16/xsourcenote-dev)

- An Xcode plugin.
- Used for writing notes when browsing source code.
- Generate a markdown article.


![XSourceNote](http://everettjf.github.io/stuff/xsourcenote/project_whole.png)


# Install

Search `XSourceNote` in [Alcatraz](http://alcatraz.io) , click install ,and restart Xcode.

# Shortcut

- Command+F4 : Add a note
- Shift+F4 : Show list of notes.


# Usage

## 0. Menu

`Xcode->Edit->XSourceNote`

or press the shortcut for each menu item.
(Menu shortcut is configurable in the `Tool` cell below)

## 1. Config
e.g.

 - Open the project(or workspace) file under the path /Users/everettjf/GitHub/XSourceNote by Xcode.
 - Open the note list window by pressing the shortcut `Shift+F4`.

 ![XSourceNote](http://everettjf.github.io/stuff/xsourcenote/project_basic.png)

 - Root Path(Required): The absolute directory path of the current project. (For convert the absolute source path to relative path)
 - Project Name 
 - Official Site 
 - Repo : Repository address.
 - Revision : Current revision number. (The unique identifier for the source revision)
 - Description.

## 2. Project Note

Note for the whole project.


## 3. Summary

The summary will be append to the end of the markdown file , which will be exported.

## 4. Tool

Config the prefix for the markdown file . (Most blog system based on markdown require the meta data).


**Down-left button to export the markdown file**

## 5. Note for the line(s)

### 1) Add a line note
Press `Command+F4` to add a note in the code editor , and the `XSourceNote` plugin will know **the line number which cursor existing , or the lines which selected** .

Writing some words in the `Quick Note` window. The note will be saved when closing the window. And an `Green Tag` will be displayed in the left sidebar of editor.


 ![XSourceNote](http://everettjf.github.io/stuff/xsourcenote/quick_note.png)


 ![XSourceNote](http://everettjf.github.io/stuff/xsourcenote/sidebar.png)



### 2）Edit notes

Pressing `Shift+F4` to open the window for the notes. Notes for the lines will be appended under the left list.

 ![XSourceNote](http://everettjf.github.io/stuff/xsourcenote/line_note.png)

- Text at upper-right of the window is the source relative path (or the absolute path when the path does not contains root path.)
- Middle-right is the source code.
- Bottom-right is the note we could edit.

(Notes will be auto-saved with 10s interval.)


### 3)Export

Click the `Tool` in the left list (the 4th item), and click the `bottom-left` button in the right panel.

- [Exported Format Sample](http://everettjf.github.io/2016/03/17/yycache-learn)


# Other

Simple note feature for Xcode, but enough for me.

Features will be develop:

- Sort notes
- Color the source code.
- Note preview.
- Auto-config root path.


# History versions

- v0.1 2016.3.21 First release

