import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Window {
    visible: true
    color: "gray"

    minimumHeight: 400
    minimumWidth: 800

    PlotFlickable{
        id: flick
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.verticalCenter
        anchors.margins: 5
    }

    //таймер для добавления новых данных.
    Timer{
        id: timer
       // running: true
        interval: 300
        repeat: true
        onTriggered: {
            var rand = (Math.random() - 0.5)*2 // [-1,1]
            flick.canvas.pushData(50 + rand*rand*rand*50)   //[0,100]
        }
    }

    // столбец кнопок для генерации новых данных для графика
    Item{
        anchors.top: parent.verticalCenter
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.horizontalCenter
        Column{
            anchors.centerIn: parent
            spacing: 5
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

            Button{
                text: "CLEAR"
                onClicked:{
                    flick.canvas.clear()
                    flick.contentWidth = flick.width
                    flick.contentX = 0
                }
                style: ButtonStyle{
                    background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 25
                                color:  "lightgreen"
                                radius: 4
                            }
                }
            }
        }
    }

    // информация о выбранной дате
    Item{
        anchors.top: parent.verticalCenter
        anchors.bottom: parent.bottom
        anchors.left: parent.horizontalCenter
        anchors.right: parent.right
        Text{
            visible: flick.canvas.selectedIndex != -1
            anchors.centerIn: parent
            font.pointSize: 12
            text: flick.canvas.selectedIndex == -1? "" :
                "DATE: " + formateDate(flick.canvas.plotData[flick.canvas.selectedIndex][0]) + "\n" +
                "VALUE: " + flick.canvas.plotData[flick.canvas.selectedIndex][1].toFixed(2)


        }
    }

    function formateDate(date){
        var m = date.getMonth()+1
        return date.getDate() + "." + m + "." + date.getFullYear()
    }
}
