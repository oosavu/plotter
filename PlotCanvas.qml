import QtQuick 2.0

Canvas{
    antialiasing: true

    property color lineColor: Qt.rgba(0.2,0.2,0.7,0.7)
    property color fillColor: Qt.rgba(0.2,0.2,0.7,0.3)
    property color dotColor: Qt.rgba(0.1,0.1,0.1,1.0)
    property color dotFillColor: Qt.rgba(0.9,0.9,0.4,1.0)
    property color selectedDotColor: Qt.rgba(0.0,0.0,0.0,1.0)
    property color selectedDotFillColor: Qt.rgba(0.9,0.4,0.9,1.0)
    property int lineWidth: 2
    property int dotRad: 7
    property int selectedDotRad: dotRad + 2

    property int selectedIndex: -1


    property real minX: 0
    property real maxX: 1
    property real minY: 0
    property real maxY: 1
    property real rangeY: maxY - minY
    property real rangeX: maxX - minX

    function calcRanges(){
        if(plotData.length == 0) return
        minX = plotData[0][0]
        maxX = plotData[plotData.length - 1][0]
        minY = plotData[0][1]
        maxY = plotData[0][1]
        for(var i = 0; i < plotData.length; i++){
            if(minY > plotData[i][1]) minY = plotData[i][1]
            if(maxY < plotData[i][1]) maxY = plotData[i][1]
        }
    }

    function click(x,y){
        if(selectedIndex != -1) {
            selectedIndex = -1
            return
        }
        for(var i = 0; i < pixData.length; i++){
            if((pixData[i][0] - x)*(pixData[i][0] - x ) < selectedDotRad*selectedDotRad &&
                (pixData[i][1] - y)*(pixData[i][1] - y) < selectedDotRad*selectedDotRad){
                selectedIndex = i
                //console.log("select: ",pixData[i][0] - x,pixData[i][1] - y, selectedIndex)
                return
            }
        }
        selectedIndex = -1
    }

    Item{
        id: di //data item
        x: 30
        y:30
        width: parent.width - 60
        height: parent.height - 40
    }

    property var plotData: []
    property var pixData: []

    function pushData(){
//        plotData.push([plotData.length,plotData.length*plotData.length])
        plotData.push([plotData.length,Math.random()])
        console.log("data pushed")

        requestPaint()
    }


    function generatePixData(){
        pixData = []
        for(var i = 0; i < plotData.length; i++){
            var pixX = di.x + di.width * (plotData[i][0] - minX) / (rangeX)
            var pixY = di.y + di.height - di.height * (plotData[i][1] - minY) / (rangeY)
            pixData.push([pixX, pixY])
        }
    }

    onPaint: {
        calcRanges()
        generatePixData()
        if(pixData.length == 0)
            return
        var ctx = getContext('2d');
        ctx.save();
        ctx.clearRect(0, 0, width, height);
        ctx.strokeStyle = lineColor
        ctx.fillStyle = fillColor
        ctx.lineWidth = lineWidth
        ctx.lineCap = "round"
        ctx.lineJoin = "round"
        ctx.textAlign = "center"
        ctx.font = "bold 12px sans-serif"

        ctx.beginPath();
        //ctx.moveTo(di.x,di.y+di.height)
        ctx.moveTo(di.x,height)
        for(var i = 0; i < pixData.length; i ++){
            ctx.lineTo(pixData[i][0],pixData[i][1])
            //console.log(pixData[i][0],pixData[i][1])
        }
        //ctx.lineTo(di.x+di.width,di.y+di.height)
        ctx.lineTo(di.x+di.width,height)
        ctx.closePath()
        ctx.fill()

        ctx.beginPath();
        ctx.moveTo(pixData[0][0], pixData[0][1])
        for(var i = 0; i < pixData.length; i ++){
            ctx.lineTo(pixData[i][0],pixData[i][1])
            //console.log(pixData[i][0],pixData[i][1])
        }
        ctx.stroke()

        ctx.strokeStyle = dotColor
        ctx.fillStyle = dotFillColor
        ctx.beginPath()
        for(var i = 0; i < pixData.length; i ++){
            ctx.ellipse(pixData[i][0] - dotRad,pixData[i][1] - dotRad,2*dotRad, 2*dotRad)

            //console.log(pixData[i][0],pixData[i][1])
        }
        ctx.fill()
        ctx.stroke()

        if(selectedIndex != -1){
            ctx.strokeStyle = selectedDotColor
            ctx.fillStyle = selectedDotFillColor
            ctx.beginPath()
            ctx.ellipse(pixData[selectedIndex][0] - selectedDotRad,
                        pixData[selectedIndex][1] - selectedDotRad,
                        2*selectedDotRad, 2*selectedDotRad)
            ctx.fill()
            ctx.stroke()
        }
        ctx.fillStyle = Qt.rgba(0,0,0,1)
        for(var i = 0; i < pixData.length; i ++){
            ctx.fillText(plotData[i][1].toFixed(1), pixData[i][0], pixData[i][1] - 2*dotRad)
        }
    }

    function paintText(ctx,x,y,text){
        ctx.beginPath()
        ctx.fillText(text,x,y)
        ctx.stroke()
    }

    Component.onCompleted:{
//        for (var i = 0; i < 10; i++)
        //    pushData()
//        requestPaint()
    }
}


