HTMLWidgets.widget({

  name: 'd3tree',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

  	    // remove the old graph
    		d3.select(el).select("svg")
    		  .remove()
    		  .html("");

    		var data = x.data;

    		// Define some 'common' variables
    		var root = data['root'];
    		var layout = data['layout'];
    		
    		//  these are the names of the key for name and value
    		var name_var = x.options.name ? x.options.name : "name";
    		var value_var = x.options.value ? x.options.value : "value";
        var dir= x.options.dir ? x.options.dir : "h";
        var activeReturn=x.options.activeReturn ? x.options.activeReturn : ['value', 'name'];
         
    		// Initialize tooltip
    		tip = d3.tip().attr('class', 'd3-tip').html(function(d) { return "<p style=\"color: #000000; background-color: #ffffff\">" + d[value_var] + "</p>"; });

    		if (layout == "collapse") {

    			var margin = {top: 20, right: 30, bottom: 20, left: 40},
    			    width = el.getBoundingClientRect().width - margin.right - margin.left,
    			    height = el.getBoundingClientRect().height - margin.top - margin.bottom;

    			root.x0 = height / 2;
    			root.y0 = 0;

  			  // bad idea I'm sure to use a function-wide counter like
  			  //  this for a unique but do for now
  			  //  revisit this;  at least better than the very commonly
  			  //  used i which could easily blow up
  			  var uniqueid = 0;
    			var duration = 750;
          var activeNode;
    			var tree = d3.layout.tree()
    			    .size([height, width]);

    			var diagonal = d3.svg.diagonal()
    			    .projection(function(d) { return (dir=='h' ? [d.y, d.x] : [d.x, d.y]) });

    			 // Append a new svg element
    			var svg = d3.select(el).append("svg")
    				.attr("width", width + margin.right + margin.left)
    			  .attr("height", height + margin.top + margin.bottom)
    			  .call(d3.behavior.zoom().on("zoom", function () {
              svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
              }))
    			  .append("g")
    			    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    			// Invoke the tip
    			svg.call(tip);

    			// Toggle children on click.
    			function click(d) {
    			  if (d.children) {
    			    d._children = d.children;
    			    d.children = null;
    			  } else {
    			    d.children = d._children;
    			    d._children = null;
    			  }
    			  
    			 if((typeof activeReturn)=='string'){
    			  activeNode = [activeReturn].reduce(function(o, k) { o[k] = d[k]; return o; }, {});  
    			 }else{
    			  activeNode = activeReturn.reduce(function(o, k) { o[k] = d[k]; return o; }, {});   
    			 } 

    			  update(d);
    			}

    			function collapse(d) {
    			  if (d.children) {
    			    d._children = d.children;
    			    d._children.forEach(collapse);
    			    d.children = null;
    			  }
    			}

    			function update(source) {

    			  // Compute the new tree layout.
    			  var nodes = tree.nodes(root).reverse(),
    			      links = tree.links(nodes);

    			  // Normalize for fixed-depth.
    			  nodes.forEach(function(d) { d.y = d.depth * 100; });

    			  // Update the nodes…
    			  var node = svg.selectAll("g.node")
    			      .data(nodes, function(d) {
    			        return d.id || (d.id = ++uniqueid);
  			        });

    			  // Enter any new nodes at the parent's previous position.
    			  var nodeEnter = node.enter().append("g")
    			      .attr("class", "node")
    			      .attr("transform", function(d) { return (dir=='h' ? "translate(" + source.y0 + "," + source.x0 + ")" :
    			             "translate(" + source.x0 + "," + source.y0 + ")") })
    			      .on("click", click)
    			      .on('mouseover', tip.show)
    		  		  .on('mouseout', tip.hide);

    			  nodeEnter.append("circle")
    			      .attr("r", 1e-6)
    			      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

    			  nodeEnter.append("text")
    			      .attr("dy", "0.35em")
    			      .text(function(d) { return d[name_var]; })
    			      .style("fill-opacity", 1e-6);

    			  // Transition nodes to their new position.
    			  var nodeUpdate = node.transition()
    			      .duration(duration)
    			      .attr("transform", function(d) { return (dir=='h' ? "translate(" + d.y + "," + d.x + ")" : "translate(" + d.x + "," + d.y + ")") });

    			  nodeUpdate.select("circle")
    			      .attr("r", 4.5)
    			      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

    			  nodeUpdate.select("text")
                .style("fill-opacity", 1)
                .attr("text-anchor", function(d) {
                      return d.children ? "end" : "start";
                     })
                .attr("transform", function(d) {return d.children ? "rotate(20)":"rotate(0)"})
                .attr("x", function(d) {
                      return d.children ? -10 : 10;
                    });

    			  // Transition exiting nodes to the parent's new position.
    			  var nodeExit = node.exit().transition()
    			      .duration(duration)
    			      .attr("transform", function(d) { return (dir=='h' ? "translate(" + source.y + "," + source.x + ")":"translate(" + source.x + "," + source.y + ")") })
    			      .remove();

    			  nodeExit.select("circle")
    			      .attr("r", 1e-6);

    			  nodeExit.select("text")
    			      .style("fill-opacity", 1e-6);

    			  // Update the links…
    			  var link = svg.selectAll("path.link")
    			      .data(links, function(d) { return d.target.id; });

    			  // Enter any new links at the parent's previous position.
    			  link.enter().insert("path", "g")
    			      .attr("class", "link")
    			      .attr("d", function(d) {
    			        var o = {x: source.x0, y: source.y0};
    			        return diagonal({source: o, target: o});
    			      });

    			  // Transition links to their new position.
    			  link.transition()
    			      .duration(duration)
    			      .attr("d", diagonal);

    			  // Transition exiting nodes to the parent's new position.
    			  link.exit().transition()
    			      .duration(duration)
    			      .attr("d", function(d) {
    			        var o = {x: source.x, y: source.y};
    			        return diagonal({source: o, target: o});
    			      })
    			      .remove();

    			  // Stash the old positions for transition.
    			  nodes.forEach(function(d) {
    			    d.x0 = d.x;
    			    d.y0 = d.y;
    			  });

			       //return data to shiny
			       var nodes1 = tree.nodes(root);
			       
			       if(typeof(Shiny) !== "undefined"){
                Shiny.onInputChange(el.id + "_update",{
                  ".nodesData": JSON.decycle(nodes1),".activeNode": JSON.stringify(activeNode)
                });
			       }

    			} // end of update() function

    			root.children.forEach(collapse);
    			update(root);

    		} else if (layout == "radial") {

    		  var diameter = 700;

    		  var tree = d3.layout.tree()
    		      .size([360, diameter / 2 - 120])
    		      .separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

    		  var diagonal = d3.svg.diagonal.radial()
    		      .projection(function(d) { return [d.y, d.x / 180 * Math.PI]; });

    		  var svg = d3.select(el).append("svg")
    		  	  .attr("width", diameter)
    		     .attr("height", diameter - 150)
    		     .call(d3.behavior.zoom().on("zoom", function () {
              svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
              }))
    		   .append("g")
    		      .attr("transform", "translate(" + (diameter - 100) / 2 + "," + (diameter - 150) / 2 + ")");

    		  // Invoke the tip
    		  svg.call(tip);

    		  var nodes = tree.nodes(root),
    		      links = tree.links(nodes);

    		  var link = svg.selectAll(".link")
    		      .data(links)
    		    .enter().append("path")
    		      .attr("class", "link")
    		      .attr("d", diagonal);

    		  var node = svg.selectAll(".node")
    		      .data(nodes)
    		    .enter().append("g")
    		      .attr("class", "node")
    		      .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })
    		      .on('mouseover', tip.show)
    		  	  .on('mouseout', tip.hide);

    		  node.append("circle")
    		      .attr("r", 4.5);

    		  node.append("text")
    		      .attr("dy", ".31em")
    		      .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
    		      .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
    		      .text(function(d) { return d[name_var]; });

    		  d3.select(self.frameElement).style("height", diameter - 150 + "px");

    		} else if (layout == "cartesian") {

    			var width = 700,
    			    height = 1000;

    			var tree = d3.layout.tree()
    			    .size([height, width - 160]);

    			var diagonal = d3.svg.diagonal()
    			    .projection(function(d) { return [d.y, d.x]; });

    			var svg = d3.select(el).append("svg")
    			    .attr("width", width)
    			    .attr("height", height)
    			    .call(d3.behavior.zoom().on("zoom", function () {
              svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
              }))
    			  .append("g")
    			    .attr("transform", "translate(40,0)");

    			 // Invoke the tip
    		  	svg.call(tip);

    			  var nodes = tree.nodes(root),
    			      links = tree.links(nodes);

    			  var link = svg.selectAll("path.link")
    			      .data(links)
    			    .enter().append("path")
    			      .attr("class", "link")
    			      .attr("d", diagonal);

    			  var node = svg.selectAll("g.node")
    			      .data(nodes)
    			    .enter().append("g")
    			      .attr("class", "node")
    			      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
    			      .on('mouseover', tip.show)
    		  		  .on('mouseout', tip.hide);

    			  node.append("circle")
    			      .attr("r", 4.5);

    			  node.append("text")
    			      .attr("dx", function(d) { return d.children ? -8 : 8; })
    			      .attr("dy", 3)
    			      .attr("text-anchor", function(d) { return d.children ? "end" : "start"; })
    			      .text(function(d) { return d[name_var]; });

    			d3.select(self.frameElement).style("height", height + "px");
    		} //end of if else


      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});