
<!-- Three.jsを使ってみよう-->
		<!-- Import maps polyfill -->
		<!-- Remove this when import maps will be widely supported -->
		<script async src="https://unpkg.com/es-module-shims@1.6.3/dist/es-module-shims.js"></script>

		<script type="importmap">
			{
				"imports": {
					"three": "../js/three/build/three.module.js",
					"three/addons/": "../js/three/jsm/"
				}
			}
		</script>
		<script type="module">

			import * as THREE from 'three';

			import { TWEEN } from 'three/addons/libs/tween.module.min.js';
			import { TrackballControls } from 'three/addons/controls/TrackballControls.js';
			import { CSS3DRenderer, CSS3DObject } from 'three/addons/renderers/CSS3DRenderer.js';

            /*
                'title','declare','data','x postion','y position'
            
           const table = [
                'table1','table1','table1',1,1,
                'table2','table2','table2',2,1,
                'table3','table3','table3',3,1,
                'table4','table4','table4',4,1,
                'table5','table5','table5',5,1,
                '6table','6table','6table',1,2,
                '7table','7table','7table',2,2,
                '8table','8table','8table',3,2,
                '9table','9table','9table',4,2,
                '10table','10table','10table',5,2
           ];
           */
			let camera, scene, renderer;
			let controls;

			const objects = [];
			const targets = { table: [], sphere: [], helix: [], grid: [] };

			init();
			animate();

			function init() {

				camera = new THREE.PerspectiveCamera( 40, window.innerWidth / window.innerHeight, 1, 10000 );
				camera.position.z = 3000;

				scene = new THREE.Scene();

				// table
                /* ここで要素のデザインを決めているので省略はできない　
					tableは'title','declare','data','x postion','y position'がひと固まりなので 5step(i+=5)になっている
				*/

				if( debug ) console.log("table[]:", table);

				//				for ( let i = 0; i < table.length; i += 5 ) {
				for ( let i = 0; i < table.length; i += 3 ) {

					const element = document.createElement( 'button' );
					element.textContent = table[i];
//**					const element = document.createElement( 'div' );
//**					element.className = 'element';
//**					element.style.backgroundColor = 'rgba(0,127,127,' + ( Math.random() * 0.5 + 0.25 ) + ')';

//**					const number = document.createElement( 'div' );
//**					number.className = 'number';
//					number.textContent = ( i / 5 ) + 1;
//**					number.textContent = ( i / 3 ) + 1;
//**					element.appendChild( number );
/**/
//**					const symbol = document.createElement( 'div' );
//**					symbol.className = 'symbol';
//**					symbol.textContent = table[ i ];
//**					element.appendChild( symbol );
/*
					const details = document.createElement( 'div' );
					details.className = 'details';
					details.innerHTML = table[ i + 1 ] + '<br>' + table[ i + 2 ];
					element.appendChild( details );
*/

					const objectCSS = new CSS3DObject( element );

					objectCSS.position.x = Math.random() * 4000 - 2000;
					objectCSS.position.y = Math.random() * 4000 - 2000;
					objectCSS.position.z = Math.random() * 4000 - 2000;

					scene.add( objectCSS );

					objects.push( objectCSS );

					//

					const object = new THREE.Object3D();
//					object.position.x = ( table[ i + 3 ] * 140 ) - 1330;
//					object.position.y = - ( table[ i + 4 ] * 180 ) + 990;  

					object.position.x = ( table[ i + 1 ] * 140 ) - 1500;
					object.position.y = - ( table[ i + 2 ] * 180 ) + 590;  

//					object.position.x = 0;
//					object.position.y = 0;  
					
					console.log("table -> obj x,y:",table[i], object.position.x, object.position.y);

					targets.table.push( object );

				}
                /**/
				// sphere
                
				const vector = new THREE.Vector3();
                /*
				for ( let i = 0, l = objects.length; i < l; i ++ ) {

					const phi = Math.acos( - 1 + ( 2 * i ) / l );
					const theta = Math.sqrt( l * Math.PI ) * phi;

					const object = new THREE.Object3D();

					object.position.setFromSphericalCoords( 800, phi, theta );

					vector.copy( object.position ).multiplyScalar( 2 );

					object.lookAt( vector );

					targets.sphere.push( object );

				}
                */
				// helix

				for ( let i = 0, l = objects.length; i < l; i ++ ) {

					const theta = i * 0.175 + Math.PI;
					const y = - ( i * 8 ) + 450;

					const object = new THREE.Object3D();

					object.position.setFromCylindricalCoords( 900, theta, y );

					vector.x = object.position.x * 2;
					vector.y = object.position.y;
					vector.z = object.position.z * 2;

					object.lookAt( vector );

					targets.helix.push( object );

				}

				// grid

				for ( let i = 0; i < objects.length; i ++ ) {

					const object = new THREE.Object3D();
/*
					object.position.x = ( ( i % 5 ) * 400 ) - 800;
					object.position.y = ( - ( Math.floor( i / 5 ) % 5 ) * 400 ) + 800;
					object.position.z = ( Math.floor( i / 25 ) ) * 1000 - 2000;
*/
					object.position.x = ( ( i % 2 ) * 200 ) - 400;
					object.position.y = ( - ( Math.floor( i / 2 ) % 2 ) * 200 ) + 400;
//					object.position.z = ( Math.floor( i / 1 ) ) * 1000 - 2000;
					object.position.z = 0;

					targets.grid.push( object );

				}

				//

				renderer = new CSS3DRenderer();
				renderer.setSize( window.innerWidth, window.innerHeight );
				
				document.getElementById( 'table_container' ).appendChild( renderer.domElement );

				//

				controls = new TrackballControls( camera, renderer.domElement );
				controls.minDistance = 500;
				controls.maxDistance = 6000;
				controls.addEventListener( 'change', render );
                
				const buttonTable = document.getElementById( 'table' );
				buttonTable.addEventListener( 'click', function () {

					transform( targets.table, 2000 );

				} );
                
               /*
				const buttonSphere = document.getElementById( 'sphere' );
				buttonSphere.addEventListener( 'click', function () {

					transform( targets.sphere, 2000 );

				} );
                */
				const buttonHelix = document.getElementById( 'helix' );
				buttonHelix.addEventListener( 'click', function () {

					transform( targets.helix, 2000 );

				} );

				const buttonGrid = document.getElementById( 'grid' );
				buttonGrid.addEventListener( 'click', function () { console.log("grid clicked:");

					transform( targets.grid, 2000 );

				} );

				transform( targets.table, 2000 );
//				transform( targets.grid, 2000 );

				//

				window.addEventListener( 'resize', onWindowResize );

			}

			function transform( targets, duration ) {

				TWEEN.removeAll();console.log("trans:", objects);
				for ( let i = 0; i < objects.length; i ++ ) {

					const object = objects[ i ];
					const target = targets[ i ];

					new TWEEN.Tween( object.position )
						.to( { x: target.position.x, y: target.position.y, z: target.position.z }, Math.random() * duration + duration )
						.easing( TWEEN.Easing.Exponential.InOut )
						.start();

					new TWEEN.Tween( object.rotation )
						.to( { x: target.rotation.x, y: target.rotation.y, z: target.rotation.z }, Math.random() * duration + duration )
						.easing( TWEEN.Easing.Exponential.InOut )
						.start();

				}

				new TWEEN.Tween( this )
					.to( {}, duration * 2 )
					.onUpdate( render )
					.start();

			}

			function onWindowResize() {

				camera.aspect = window.innerWidth / window.innerHeight;
				camera.updateProjectionMatrix();

				renderer.setSize( window.innerWidth, window.innerHeight );

				render();

			}

			function animate() {

				requestAnimationFrame( animate );

				TWEEN.update();

				controls.update();

			}

			function render() {

				renderer.render( scene, camera );

			}

		</script>