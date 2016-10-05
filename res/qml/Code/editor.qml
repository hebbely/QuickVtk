import QtQuick 2.6
import QtQuick.Controls 1.4

import App 1.0 as App
import Lib 1.0 as Lib

Item {
    id: root;

    property var editor: App.editor;

    clip: true;

    function activate() {
        textEdit.forceActiveFocus();
    }

    Flickable {
        id: scrollView;

        anchors.left: lines.right;
        anchors.top: parent.top;
        anchors.bottom: search.visible ? search.top : footer.top;
        anchors.right: parent.right;

        contentWidth: textEdit.width;
        contentHeight: textEdit.height;

        boundsBehavior: Flickable.StopAtBounds

        Rectangle {
            id: cursorBg;

            anchors.left: parent.left;
            anchors.right: parent.right;
            y: height * editor.line;
            height: textEdit.cursorRectangle.height;

            color: "#11ddddff"
        }

        Repeater {
            model: App.editor.errors;

            delegate: Error {
                anchors.left: parent.left;
                anchors.right: parent.right;

                height: cursorBg.height;
                y: (model.line - 1) * height;

                error: model;
            }
        }

        Lib.TextEdit {
            id: textEdit

            width: Math.max(implicitWidth, root.width - lines.width);
            leftPadding: 4;

            font.pointSize: editor.fontSize;
            Keys.onPressed: event.accepted = editor.onKeyPressed(event.key, event.modifiers, event.text);
        }
    }

    Rectangle {
        id: lines;

        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.bottom: footer.top;

        width: linesCol.width;
        color: "#21252B"

        Column {
            id: linesCol;

            y: -scrollView.contentY;

            Repeater {
                model: textEdit.lineCount;

                delegate: Text {
                    anchors.right: parent.right;
                    rightPadding: 8;
                    leftPadding: 8;

                    font.family: textEdit.font.family;
                    font.pointSize: editor.fontSize;
                    verticalAlignment: Text.AlignVCenter;

                    color: index == editor.line ? "#fff" : "#6E7582"
                    text: index + 1;
                }
            }
        }

        Rectangle {
            anchors.top: parent.top;
            anchors.bottom: parent.bottom;
            anchors.right: parent.right;

            width: 1;
            color: "#343842"
        }
    }

    Search {
        id: search;

        anchors.left: parent.left;
        anchors.bottom: footer.top;
        anchors.right: parent.right;

        refocus: textEdit;
    }

    Footer {
        id: footer;

        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
    }

    Connections {
		target: editor;
		onUpdateSelection: textEdit.select(editor.selectionStart, editor.selectionEnd);
	}

    Component.onCompleted: {
        editor.document       = textEdit.textDocument;
        editor.selectionStart = Qt.binding(function() { return textEdit.selectionStart; });
        editor.selectionEnd   = Qt.binding(function() { return textEdit.selectionEnd; });
        textEdit.forceActiveFocus();
    }
}
