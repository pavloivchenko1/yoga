package br.com.zup.javaswing

import java.awt.Dimension
import javax.swing.JComponent


class YogaComponent : JComponent(){

  private val mYogaNodes: Map<JComponent, YogaNode>? = null
  private val mYogaNode: YogaNode? = null

  init{

  }



  override fun getPreferredSize(): Dimension = Dimension()

}
