/* 
This file borrows heavily from code written by Mike Bostock.
In particular, his Reingold-Tilford Tree examples:
	(1) Collapsable -- http://bl.ocks.org/mbostock/4339083
	(2) Radial -- http://bl.ocks.org/mbostock/4063550
	(3) Cartesian -- http://bl.ocks.org/mbostock/4339184
*/

// Custom shiny output binding -- http://shiny.rstudio.com/articles/building-outputs.html
var d3OutputBinding = new Shiny.OutputBinding();
$.extend(d3OutputBinding, {
    find: function(scope) {
		return $(scope).find('.d3plot');
    },
    renderValue: function(el, data) {

	    // remove the old graph
		var svg = d3.select(el).select("svg");
		svg.remove();

		$(el).html("");

		// Define some 'common' variables 
		var root = data['root'];
		var layout = data['layout'];

		// Initialize tooltip 
		tip = d3.tip().attr('class', 'd3-tip').html(function(d) { return "<p style=\"color: #000000; background-color: #ffffff\">" + d.value + "</p>"; });

		if (layout == "collapse") {
			
			var margin = {top: 0, right: 30, bottom: 20, left: 40},
			    width = 700 - margin.right - margin.left,
			    height = 800 - margin.top - margin.bottom;

			root.x0 = height / 2;
			root.y0 = 0;
			    
			var i = 0,
			    duration = 750;
			
			var tree = d3.layout.tree()
			    .size([height, width]);

			var diagonal = d3.svg.diagonal()
			    .projection(function(d) { return [d.y, d.x]; });

			 // Append a new svg element
			var svg = d3.select(el).append("svg")
				.attr("width", width + margin.right + margin.left)
			    .attr("height", height + margin.top + margin.bottom)
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
			  nodes.forEach(function(d) { d.y = d.depth * 90; });

			  // Update the nodes…
			  var node = svg.selectAll("g.node")
			      .data(nodes, function(d) { return d.id || (d.id = ++i); });

			  // Enter any new nodes at the parent's previous position.
			  var nodeEnter = node.enter().append("g")
			      .attr("class", "node")
			      .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
			      .on("click", click)
			      .on('mouseover', tip.show)
		  		  .on('mouseout', tip.hide);

			  nodeEnter.append("circle")
			      .attr("r", 1e-6)
			      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

			  nodeEnter.append("text")
			      .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
			      .attr("dy", ".35em")
			      .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
			      .text(function(d) { return d.name; })
			      .style("fill-opacity", 1e-6);

			  // Transition nodes to their new position.
			  var nodeUpdate = node.transition()
			      .duration(duration)
			      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

			  nodeUpdate.select("circle")
			      .attr("r", 4.5)
			      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

			  nodeUpdate.select("text")
			      .style("fill-opacity", 1);

			  // Transition exiting nodes to the parent's new position.
			  var nodeExit = node.exit().transition()
			      .duration(duration)
			      .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
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
            console.log(nodes1);
            Shiny.onInputChange("nodesData", JSON.decycle(nodes1));
			  
			} // end of update() function

			root.children.forEach(collapse);
			update(root);

			d3.select(self.frameElement).style("height", "800px");

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
		      .text(function(d) { return d.name; });

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
			      .text(function(d) { return d.name; });

			d3.select(self.frameElement).style("height", height + "px");
		} //end of if else

  	} // end of renderValue
}); // end of .extend

Shiny.outputBindings.register(d3OutputBinding, 'cpsievert.d3binding');