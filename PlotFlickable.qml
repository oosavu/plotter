import QtQuick 2.0


//элемент позволяет интерактивно работать с графиком (изменять размер, проматывать)
Flickable {
    id: flick
    contentWidth: width
    contentHeight: height
    boundsBehavior: Flickable.StopAtBounds
    property alias canvas: canvas
    clip: true

    onWidthChanged: {
        if(contentWidth < width) contentWidth = width
        canvas.requestPaint()
    }
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
        // изменение размера графика
        onWheel:{
            var prevPersent = ( wheel.x)/(flick.contentWidth)
            var coef = wheel.angleDelta.y < 0? 0.98 : 1.02
            if(flick.contentWidth * coef < flick.width) flick.contentWidth = flick.width
            else flick.contentWidth = flick.contentWidth * coef
            var newContentX = prevPersent*flick.contentWidth - wheel.x + flick.contentX
            if(newContentX < 0) newContentX = 0
            if(newContentX > flick.contentWidth - flick.width) newContentX =flick.contentWidth - flick.width
            flick.contentX = newContentX
            flick.returnToBounds()
            canvas.requestPaint()
        }
        // клик по графику
        onClicked: {
            console.log(flick.contentX, flick.contentWidth, flick.width)
            canvas.click(mouse.x , mouse.y)
            canvas.requestPaint()
        }
    }
}
