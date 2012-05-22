import java.awt.*;
import java.awt.event.KeyEvent;
import java.io.File;

		/**
		 * Seam carving backward energy
		 */
		PImage img;
		float[][] imgMValue,imgEnergy,imgRGB;
		int[][] imgKTrack;
		float minEnergy;
		float[] minMValue,r,g,b;
		int[] mx,my;
		int[][] tempP;
		int x2,y2,loc,wid,hei,i=0;
		String filename,dir;
		void setup()
		{
			FileDialog filedialog = new FileDialog(frame, "Choose an image file");
			filedialog.setVisible(true);
			filename = filedialog.getFile();
			dir = filedialog.getDirectory();
			img = loadImage(dir+File.separator+filename);
			wid=img.width;
	                hei=img.height;
	                imgRGB = new float[wid][hei];
			imgEnergy = new float[wid][hei];
			imgMValue = new float[wid][hei];
			imgKTrack = new int[wid][hei];
		  	minMValue = new float[hei];
		  	mx = new int[hei];
		  	my = new int[hei];
	                r = new float[img.pixels.length];
	                g = new float[img.pixels.length];
	                b = new float[img.pixels.length];
	                tempP = new int[wid][hei];
	                size(wid,hei);
	                image(img,0,0);
		}
		public void draw()
		{
			img.loadPixels();
                        calRGB();
			calEnergy();
			calSeamAndKMatrix();
			calMinMVertical();
			/*if(keyPressed&&wid>1)
			{
			  if(keyCode==KeyEvent.VK_LEFT)
		          {
                              calRGB();
			      calEnergy();
			      calSeamAndKMatrix();
			      calMinMVertical();
			      shiftPixels();
			      size(wid,hei);
    	       		      image(img,0,0);
		          }
			}*/
		}// end void draw

       void keyPressed()
        {
	          if(keyCode==KeyEvent.VK_LEFT)
	          {
	        	  if (wid==1)
			      {stop();}
	        	  else
	        	  {/*
			              calRGB();
				      calEnergy();
				      calSeamAndKMatrix();
				      calMinMVertical();*/
				      shiftPixels();
				      size(wid,hei);
				      image(img,0,0);
	        	  }
			      
	          }
         }

	//////////////////////////////////////////////Methods///////////////////////////////////////////////////	
		
		public void calRGB()
		  {
			  // Calculation RGB
			  //System.out.println("Start finding RGB!");
			  for (int y=0;y<hei;y++)
			  {
			    for (int x=0;x<wid;x++)
			    {
			      loc = x + y*img.width;
			      r[loc] = red (img.pixels[loc]);
			      g[loc] = green (img.pixels[loc]);
			      b[loc] = blue (img.pixels[loc]);
			      imgRGB[x][y]=r[loc]+g[loc]+b[loc];
			     //System.out.print(imgRGB[x][y]+"("+loc+")  ");
				  tempP[x][y]=img.pixels[loc];
			    }// end for x (RGB)
			    minMValue[y]=0;//set all minMValue = 0
			    //System.out.println();
			  }// end for y (RGB)
			  
		  }
		
		  public void calEnergy()
		  {
			  //System.out.println("Start finding energy! [Backward]");
			  
			  //Calculation energy
			 
			 for (int y=0;y<hei;y++)
			 {
			   for (int x=0;x<wid;x++)
			   {
			     loc = x + y*wid;
			     if (y==0) // The first row
			     {
			       if (x==0)
			       {//left corner (0,0)
			         imgEnergy[x][y] = (abs(imgRGB[x][y]-imgRGB[x+1][y])+abs(imgRGB[x][y]-imgRGB[x][y+1]))/2;
			         //System.out.println("Image energy(first row) = "+imgEnergy[x][y]);
			       }
			       else if(x==wid-1)
			       {//right corner (width-1,0)
			         imgEnergy[x][y] = (abs(imgRGB[x-1][y]-imgRGB[x][y])+abs(imgRGB[x][y]-imgRGB[x][y+1]))/2;
			         //System.out.println("Image energy(first row) = "+imgEnergy[x][y]);
			       }
			       else
			       {
			         imgEnergy[x][y] = (abs(imgRGB[x-1][y]-imgRGB[x+1][y])+abs(imgRGB[x][y]-imgRGB[x][y+1]))/2;
			         //System.out.println("Image energy(first row) = "+imgEnergy[x][y]);
			       }
			     }
			     else if (y==hei-1)//The last row
			     {
			       if (x==0)
			       {//left corner (0,height-1)
			         imgEnergy[x][y] = (abs(imgRGB[x][y]-imgRGB[x+1][y])+abs(imgRGB[x][y-1]-imgRGB[x][y]))/2;
			         //System.out.println("Image energy(last row) = "+imgEnergy[x][y]);
			       }
			       else if(x==wid-1)
			       {//right corner (width-1,height-1)
			         imgEnergy[x][y] = (abs(imgRGB[x-1][y]-imgRGB[x][y])+abs(imgRGB[x][y-1]-imgRGB[x][y]))/2;
			        // System.out.println("Image energy(last row) = "+imgEnergy[x][y]);
			       }
			       else
			       {
			         imgEnergy[x][y] = (abs(imgRGB[x-1][y]-imgRGB[x+1][y])+abs(imgRGB[x][y-1]-imgRGB[x][y]))/2;
			         //System.out.println("Image energy(last row) = "+imgEnergy[x][y]);
			       }
			     }
			     else
			     {
			       if (x==0)
			       {//left (0,y)
			         imgEnergy[x][y] = (abs(imgRGB[x][y]-imgRGB[x+1][y])+abs(imgRGB[x][y-1]-imgRGB[x][y+1]))/2;
			         //System.out.println("Image energy(last row) = "+imgEnergy[x][y]);
			       }
			       else if(x==wid-1)
			       {//right (width-1,y)
			         imgEnergy[x][y] = (abs(imgRGB[x-1][y]-imgRGB[x][y])+abs(imgRGB[x][y-1]-imgRGB[x][y+1]))/2;
			        // System.out.println("Image energy(last row) = "+imgEnergy[x][y]);
			       }
			       else
			       {
			         imgEnergy[x][y] = (abs(imgRGB[x-1][y]-imgRGB[x+1][y])+abs(imgRGB[x][y-1]-imgRGB[x][y+1]))/2;
			         //System.out.println("Image energy(last row) = "+imgEnergy[x][y]);
			       }
			     }// end if y=0
			     //System.out.print(imgEnergy[x][y]+" loc "+loc+" \t");
			   }//end for x (energy)
			   //System.out.println();
			 } //end for y (energy)
		  }
		
		  public void calSeamAndKMatrix()
		  {
			  //System.out.println("Start finding the best seam! [Backward]");
			  
			  for (int y=0;y<hei;y++)
			  {
			    for (int x=0;x<wid;x++)
			    {
			      loc = x + y*wid;
			      //first row, no calculation the best seam
			      //start calculation the best seam at the next row
			      if (y!=0) //y=1 to hei-1
			      {
			        if (x==0) //1st pixel of each row
			        {//find M (0,y>0)
			          minEnergy=min(imgEnergy[x][y-1],imgEnergy[x+1][y-1]);
			          imgMValue[x][y]=imgEnergy[x][y]+minEnergy;
			          if (minEnergy==imgEnergy[x+1][y-1])
			          {imgKTrack[x][y]=3;}
			          else
			          {imgKTrack[x][y]=2;}
			        }
			        else if (x==wid-1) //last pixel of each row
			        {//find M (width-1,y>0)
			          minEnergy=min(imgEnergy[x-1][y-1],imgEnergy[x][y-1]);
			          imgMValue[x][y]=imgEnergy[x][y]+minEnergy;
			          if (minEnergy==imgEnergy[x][y-1])
			          {imgKTrack[x][y]=2;}
			          else
			          {imgKTrack[x][y]=1;}
			        }
			        else // pixels that are between 1st and last pixels
			        {
			          minEnergy=min(imgEnergy[x-1][y-1],imgEnergy[x][y-1],imgEnergy[x+1][y-1]);
			          imgMValue[x][y]=imgEnergy[x][y]+minEnergy;
			          if (minEnergy==imgEnergy[x+1][y-1])
			          {imgKTrack[x][y]=3;}
			          else if (minEnergy==imgEnergy[x][y-1])
			          {imgKTrack[x][y]=2;}
			          else
			          {imgKTrack[x][y]=1;}
			        }
			      }
			      else
			      {
			        imgMValue[x][y]=imgEnergy[x][y];
			        imgKTrack[x][y]=0;
			      }//end if-else y=1
			      //System.out.print(imgMValue[x][y]+"("+loc+")  ");
			    }//end for x (best seam)
			    //System.out.println();
			  }//end for y (best seam)
		  }

		public void calLastRow()
		  {
		  int y=hei-1;
		  minMValue[y]=imgMValue[0][y]; // first, set minimun M of last row to M value of the 1st pixel
		    for (int x=0;x<wid;x++) //finding minimum M of last row
		    {
		      if (minMValue[y]>=imgMValue[x][y])
		      {
		        minMValue[y]=imgMValue[x][y];
		        mx[y]=x;
		        my[y]=y;
		      }
		    }
		  }// end calLastRow
		  
		  public void calMinMVertical()
		  {
			  calLastRow();
			  for (int y=hei-1;y>=0;y--)
			  {
			    for (int x=0;x<wid;x++)
			    {
			    	if(y<hei-1) //y=hei-2 to 0
			    	{
			    		if(mx[y+1]==0) //if x of lower row =0
			    		{
					    	if (imgMValue[mx[y+1]][y]<imgMValue[mx[y+1]+1][y]) // if x=0 < x=1
					    	{
					    		minMValue[y]=imgMValue[mx[y+1]][y];
					    		mx[y]=mx[y+1];
					    	}
					    	else // if x=0>x=1
					    	{
					    		minMValue[y]=imgMValue[mx[y+1]+1][y];
					    		mx[y]=mx[y+1]+1;
					    	}
					        my[y]=y;
					    }
			    		else if(mx[y+1]==wid-1)// previous x==wid-1
			    		{
			    			if (imgMValue[mx[y+1]][y]<imgMValue[mx[y+1]-1][y])
					    	{
					    		minMValue[y]=imgMValue[mx[y+1]][y];
					    		mx[y]=mx[y+1];
					    	}
					    	else
					    	{
					    		minMValue[y]=imgMValue[mx[y+1]-1][y];
					    		mx[y]=mx[y+1]-1;
					    	}
			    			my[y]=y;
			    		}
			    		else //previous x!=0||x!=wid-1 (1 to wid-2)
			    		{
			    			if (imgMValue[mx[y+1]][y]<imgMValue[mx[y+1]-1][y]&&imgMValue[mx[y+1]][y]<imgMValue[mx[y+1]+1][y])
					    	{
					    		minMValue[y]=imgMValue[mx[y+1]][y];
					    		mx[y]=mx[y+1];
					    	}
					    	else if (imgMValue[mx[y+1]+1][y]<imgMValue[mx[y+1]-1][y]&&imgMValue[mx[y+1]+1][y]<imgMValue[mx[y+1]][y])
					    	{
					    		minMValue[y]=imgMValue[mx[y+1]+1][y];
					    		mx[y]=mx[y+1]+1;
					    	}
					    	else
					    	{
					    		minMValue[y]=imgMValue[mx[y+1]-1][y];
					    		mx[y]=mx[y+1]-1;
					    	}
			    			my[y]=y;
			    		}
			    	}
			    }// end for x (Find min M)
			    stroke(225, 214, 41);
			    point(mx[y],my[y]);
			    //System.out.print(imgRGB[mx[y]][my[y]]+"("+(mx[y]+my[y]*wid)+")RGB\t");
			    //System.out.println(minMValue[y]+"("+(mx[y]+my[y]*wid)+")\t");
			  }// end for y (Find min M)
		  }
		  
		  public void shiftPixels()
		  {
			  PImage nImg = createImage(wid-1,hei,RGB); 
			  //System.out.println("\nBegin shifting");
			  for (int y=0;y<hei;y++)
			  {
				  x2=mx[y];
				  y2=my[y];     
				  for (int x=0;x<wid;x++)
				  {
	                            loc = x + y*wid;
					  if (x2<wid-1)
					  {
						  /*
						  imgKTrack[x2][y2]=imgKTrack[x2+1][y2];
						  imgMValue[x2][y2]=imgMValue[x2+1][y2];
	                                          imgRGB[x2][y2]=imgRGB[x2+1][y2];
	                                          */
	                                          tempP[x2][y2]=tempP[x2+1][y2];
	                                          x2++;
					  }
	                  //System.out.print(imgRGB[x][y]+"("+loc+")  ");
	                  //System.out.print(tempP[x][y]+"("+loc+")  ");
				  }//end for x
				  //System.out.println();
			  }//end for y
			  for (int y=0;y<hei;y++)
			  {
				  for (int x=0;x<wid-1;x++)
				  {
					  loc = x + y*wid;
					  nImg.pixels[i++]=tempP[x][y];
					  //System.out.print(nImg.pixels[i-1]+"("+(i-1)+")  ");
				  }//end for x
				  //System.out.println();
			  }//end for y
			  i=0;
			  img=nImg;
                          img.updatePixels();
			  wid=img.width;
	                  for (int y=0;y<hei;y++)
			  {
				  for (int x=0;x<wid;x++)
				  {
					  loc = x + y*wid;
					  //System.out.print(img.pixels[loc]+"("+loc+")  ");
				  }//end for x
				  //System.out.println();
			  }//end for y
	          //System.out.println("End shifting");
	          //stop();
		  }//end Shift


