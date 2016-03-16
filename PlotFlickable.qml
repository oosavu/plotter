import QtQuick 2.0

Flickable {
    id: flick
    contentWidth: width
    contentHeight: height
    boundsBehavior: Flickable.StopAtBounds
    property alias canvas: canvas
    clip: true

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Rectangle{
        color: "white"
        width: flick.contentWidth
        height: flick.contentHeight
        PlotCanvas{
            anchors.fill: parent
            id: canvas
        }
    }

    MouseArea{
        anchors.fill: parent
        onWheel:{
            //var prevPersent = (flick.contentX + wheel.x)/(flick.contentWidth - flick.contentX - wheel.x)
            var prevPersent = (flick.contentX + wheel.x)/(flick.contentWidth)

            var coef = wheel.angleDelta.y < 0? 0.98 : 1.02
            if(flick.contentWidth * coef < flick.width) flick.contentWidth = flick.width
            //if(flick.contentWidth * coef < flick.width ) return
            else flick.contentWidth = flick.contentWidth * coef
            //flick.contentX =flick.contentWidth*wheel.x/flick.width //flick.contentX + wheel.x
            //var newContentX = (prevPersent*(flick.contentWidth - wheel.x) - wheel.x)/ (prevPersent + 1)
            var newContentX = prevPersent*flick.contentWidth - wheel.x
            if(newContentX < 0) newContentX = 0
            if(newContentX > flick.contentWidth - flick.width) newContentX =flick.contentWidth - flick.width
            flick.contentX = newContentX
            flick.returnToBounds()
            canvas.requestPaint()
        }
        onClicked: {
            console.log(flick.contentX, flick.contentWidth, flick.width)
            canvas.click(mouse.x , mouse.y)
            canvas.requestPaint()
        }
    }
}
