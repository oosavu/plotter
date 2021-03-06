import QtQuick 2.0

//Элемент для рисования графика.
Canvas{
    antialiasing: true

    //цвета различных элементов графика
    property color lineColor: Qt.rgba(0.2,0.2,0.7,0.7)
    property color fillColor: Qt.rgba(0.2,0.2,0.7,0.3)
    property color dotColor: Qt.rgba(0.1,0.1,0.1,1.0)
    property color dotFillColor: Qt.rgba(0.9,0.9,0.4,1.0)
    property color selectedDotColor: Qt.rgba(0.0,0.0,0.0,1.0)
    property color selectedDotFillColor: Qt.rgba(0.9,0.4,0.9,1.0)
    property color dateRectFillColor: Qt.rgba(0.5,0.7,0.3,1.0)
    property color dateRectBoundColor: Qt.rgba(0.5,0.1,0.3,1.0)

    //толщина линии графика
    property int lineWidth: 2
    //радиус точки на графике
    property int dotRad: 7
    //радиус выбранной точки
    property int selectedDotRad: dotRad + 2
    //индекс выбранной точки. -1 = не выбрано
    property int selectedIndex: -1

    //массив данных для графика.  [Date,value]
    property var plotData: []
    //пиксельные координаты точек графика
    property var pixData: []
    //начальная дата
    property var startDate

    //обработка нажатия. производит поиск по пиксельным координатам, выделяет точку на графике
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

    // вспомогательный элемент для позиционирования данных графика
    Item{
        id: di //data item
        x: 30
        y:30
        width: parent.width - 60
        height: parent.height - 70
    }


    // Добавление нового значения данных. Если данный пусты,
    // генерирует случайную дату. иначе добавляет в конец массива
    function pushData(val){
        if(plotData.length == 0) {
            startDate = randomDate()
            plotData.push([startDate,val])
        }
        else{
            var lastDate = plotData[plotData.length -1][0]
            var nextDate = new Date(lastDate)
            nextDate.setDate(lastDate.getDate() + 1)
            plotData.push([nextDate,val])
        }
        requestPaint()
    }
    //Отчистка данных графика
    function clear(){
        plotData = []
        selectedIndex = -1
        requestPaint()
    }

    //формирует пиксельные координаты из данных, учитывая масштабирование
    function generatePixData(){
        pixData = []
        if(plotData.length == 0) return
        if(plotData.length == 1){
            pixData.push([di.x+ di.width/2, di.y + di.height/2])
            return
        }

        var minY = plotData[0][1]
        var maxY = plotData[0][1]
        for(var i = 0; i < plotData.length; i++){
            if(minY > plotData[i][1]) minY = plotData[i][1]
            if(maxY < plotData[i][1]) maxY = plotData[i][1]
        }

        for(var i = 0; i < plotData.length; i++){
            var pixX = di.x + di.width * i / (plotData.length-1)
            var pixY = di.y + di.height - di.height * (plotData[i][1] - minY) / (maxY - minY)
            pixData.push([pixX, pixY])
        }
    }

    onPaint: {
        generatePixData()
        var ctx = getContext('2d');
        ctx.clearRect(0, 0, width, height);
        if(pixData.length == 0)
            return
        ctx.strokeStyle = lineColor
        ctx.fillStyle = fillColor
        ctx.lineWidth = lineWidth
        ctx.lineCap = "round"
        ctx.lineJoin = "round"
        ctx.textAlign = "center"
        ctx.font = "bold 12px sans-serif"

        //высота прямоугольника с числом  по оси x
        var rectHr = 10
        //ширина прямоугольника с числом по оси x
        var rectWr = 12
        // пиксельная координата по оси Y
        var rectY = di.y + di.height + 2 * rectHr
        // отображать дни или месяцы
        var showDays = di.width / plotData.length > 2* rectWr + 1

        //отрисовка графика
        ctx.beginPath();
        ctx.moveTo(0,height)
        ctx.lineTo(0, pixData[0][1])
        for(var i = 0; i < pixData.length; i ++)
            ctx.lineTo(pixData[i][0],pixData[i][1])
        ctx.lineTo(width, pixData[pixData.length-1][1])
        ctx.lineTo(width,height)
        ctx.closePath()
        ctx.fill()

        // отрисовка линии графика
        ctx.beginPath();
        ctx.moveTo(pixData[0][0], pixData[0][1])
        for(var i = 0; i < pixData.length; i ++)
            ctx.lineTo(pixData[i][0],pixData[i][1])
        ctx.stroke()

        if(showDays){
            // отрисовка точек графика
            ctx.strokeStyle = dotColor
            ctx.fillStyle = dotFillColor
            ctx.beginPath()
            for(var i = 0; i < pixData.length; i ++)
                ctx.ellipse(pixData[i][0] - dotRad,pixData[i][1] - dotRad,2*dotRad, 2*dotRad)
            ctx.fill()
            ctx.stroke()

            // отрисовка выбранной даты
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

            // отрисовка значений
            ctx.fillStyle = Qt.rgba(0,0,0,1)
            for(var i = 0; i < pixData.length; i ++)
                ctx.fillText(plotData[i][1].toFixed(1), pixData[i][0], pixData[i][1] - 2*dotRad)
        }

        ctx.fillStyle = dateRectFillColor
        ctx.strokeStyle = dateRectBoundColor

        // если масштаб позволяет отрисовывать числа
        if(showDays){
            for(var i = 0; i < pixData.length; i ++){
                drawSmothRect(ctx,pixData[i][0] - rectWr,rectY - rectHr,
                              2*rectWr,2*rectHr, 3)
                ctx.fill()
                ctx.stroke()
            }
            ctx.fillStyle = Qt.rgba(0,0,0,1)
            for(var i = 0; i < pixData.length; i ++){
                ctx.fillText(plotData[i][0].getDate(), pixData[i][0], rectY + rectHr/2)
            }
        }
        else{
            //отрисовка прямоугольников с месяцами
            var currMonth = plotData[0][0].getMonth()
            var xStart = pixData[0][0]
            for(var i = 0; i < pixData.length; i ++){
                if(plotData[i][0].getMonth() != currMonth || i == pixData.length - 1){
                    var cuw = pixData[i-1][0] - xStart
                    if(cuw > 3*rectWr){
                        ctx.fillStyle = dateRectFillColor
                        ctx.strokeStyle = dateRectBoundColor
                        drawSmothRect(ctx,xStart,rectY - rectHr,
                                      cuw,2*rectHr, 3)
                        ctx.fill()
                        ctx.stroke()
                        ctx.fillStyle = Qt.rgba(0,0,0,1)
                        var dateFullString = monthNames[currMonth] + " " + plotData[i-1][0].getFullYear()
                        var dateString = monthNames[currMonth]
                        if(ctx.measureText(dateFullString).width < cuw )
                            ctx.fillText(dateFullString,xStart + cuw/2, rectY + rectHr/2)
                        else if(ctx.measureText(dateString).width < cuw )
                            ctx.fillText(dateString,xStart + cuw/2, rectY + rectHr/2)
                    }
                    xStart = pixData[i][0]
                    currMonth = plotData[i][0].getMonth()
                }
            }
        }
    }

    function randomInteger(min, max) {
        var rand = min + Math.random() * (max + 1 - min);
        rand = Math.floor(rand);
        return rand;
    }

    function randomDate() {
        var year  = randomInteger(1972,2016)
        var month = randomInteger(0,11)
        var day = randomInteger(0,30)
        return new Date(year,month,day)
    }

    function drawSmothRect(ctx,x,y,w,h,rad)
    {
        ctx.beginPath()
        ctx.moveTo(x+w-rad , y)
        ctx.quadraticCurveTo(x+w,y,x+w,y+rad)
        ctx.lineTo(x+w , y+h-rad)
        ctx.quadraticCurveTo(x+w,y+h,x+w-rad,y+h)
        ctx.lineTo(x+rad , y+h )
        ctx.quadraticCurveTo(x,y+h,x,y+h-rad)
        ctx.lineTo(x , y+rad )
        ctx.quadraticCurveTo(x,y,x+rad,y)
        ctx.closePath()
        ctx.fill()
    }

    property var monthNames: ["January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ]

}


