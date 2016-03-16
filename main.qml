import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Window {
    visible: true
    color: "gray"

    minimumHeight: 400
    minimumWidth: 600

    PlotFlickable{
        id: flick
//        Rectangle{
//            anchors.fill: parent
//            color: "red"
//        }
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.verticalCenter
        anchors.margins: 5
    }
    Timer{
        id: timer
       // running: true
        interval: 300
        repeat: true
        onTriggered: {
            console.log("d push")
            flick.canvas.pushData()
        }
    }

    Item{
        anchors.top: parent.verticalCenter
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Column{
            anchors.centerIn: parent
            Button{
                text: timer.running? "STOP" : "START"
                onClicked:{
                    timer.running? timer.stop() : timer.start()
                }
                style: ButtonStyle{
                    background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 25
                                color: timer.running ? "red" : "lightgreen"
                                radius: 4
                            }
                }
            }
        }
    }
}
